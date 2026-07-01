// tb_axi_lite_master_cmd_if.sv
// Testbench for axi_lite_master_cmd_if.v
// Drives the simple cmd/resp interface and checks that the module correctly
// generates AXI-Lite write (AW+W->B) and read (AR->R) transactions, and that
// it asserts timeout_error when a slave never responds.

`timescale 1ns/1ps

module tb_axi_lite_master_cmd_if;

    localparam CLK_PERIOD = 10;

    reg clk = 0;
    reg rst_n = 0;

    reg  [31:0] cmd_addr;
    reg  [31:0] cmd_wdata;
    reg         cmd_is_write;
    reg         cmd_valid;
    wire        cmd_ready;

    wire [31:0] resp_rdata;
    wire [1:0]  resp_axi_status;
    wire        resp_valid;
    reg         resp_ack;

    wire [31:0] m_axi_awaddr;
    wire        m_axi_awvalid;
    reg         m_axi_awready;
    wire [31:0] m_axi_wdata;
    wire [3:0]  m_axi_wstrb;
    wire        m_axi_wvalid;
    reg         m_axi_wready;
    reg  [1:0]  m_axi_bresp;
    reg         m_axi_bvalid;
    wire        m_axi_bready;
    wire [31:0] m_axi_araddr;
    wire        m_axi_arvalid;
    reg         m_axi_arready;
    reg  [31:0] m_axi_rdata;
    reg  [1:0]  m_axi_rresp;
    reg         m_axi_rvalid;
    wire        m_axi_rready;
    wire        timeout_error;

    integer pass_count = 0;
    integer fail_count = 0;

    axi_lite_master_cmd_if #(
        .TIMEOUT_CYCLES(50)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .cmd_addr(cmd_addr), .cmd_wdata(cmd_wdata), .cmd_is_write(cmd_is_write),
        .cmd_valid(cmd_valid), .cmd_ready(cmd_ready),
        .resp_rdata(resp_rdata), .resp_axi_status(resp_axi_status),
        .resp_valid(resp_valid), .resp_ack(resp_ack),
        .m_axi_awaddr(m_axi_awaddr), .m_axi_awvalid(m_axi_awvalid), .m_axi_awready(m_axi_awready),
        .m_axi_wdata(m_axi_wdata), .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wvalid(m_axi_wvalid), .m_axi_wready(m_axi_wready),
        .m_axi_bresp(m_axi_bresp), .m_axi_bvalid(m_axi_bvalid), .m_axi_bready(m_axi_bready),
        .m_axi_araddr(m_axi_araddr), .m_axi_arvalid(m_axi_arvalid), .m_axi_arready(m_axi_arready),
        .m_axi_rdata(m_axi_rdata), .m_axi_rresp(m_axi_rresp),
        .m_axi_rvalid(m_axi_rvalid), .m_axi_rready(m_axi_rready),
        .timeout_error(timeout_error)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    task check(string name, logic cond);
        if (cond) begin
            pass_count++;
            $display("[PASS] %s", name);
        end else begin
            fail_count++;
            $display("[FAIL] %s", name);
        end
    endtask

    // Simple slave-side responder: accepts immediately, returns OKAY
    task automatic respond_okay_write();
        @(posedge clk);
        m_axi_awready = 1'b1;
        m_axi_wready  = 1'b1;
        @(posedge clk);
        m_axi_awready = 1'b0;
        m_axi_wready  = 1'b0;
        m_axi_bvalid  = 1'b1;
        m_axi_bresp   = 2'b00;
        @(posedge clk);
        while (!m_axi_bready) @(posedge clk);
        m_axi_bvalid = 1'b0;
    endtask

    task automatic respond_okay_read(input [31:0] data);
        @(posedge clk);
        m_axi_arready = 1'b1;
        @(posedge clk);
        m_axi_arready = 1'b0;
        m_axi_rvalid  = 1'b1;
        m_axi_rresp   = 2'b00;
        m_axi_rdata   = data;
        @(posedge clk);
        while (!m_axi_rready) @(posedge clk);
        m_axi_rvalid = 1'b0;
    endtask

    task automatic issue_write(input [31:0] addr, input [31:0] data);
        cmd_addr     = addr;
        cmd_wdata    = data;
        cmd_is_write = 1'b1;
        cmd_valid    = 1'b1;
        @(posedge clk);
        while (!cmd_ready) @(posedge clk);
        cmd_valid = 1'b0;
    endtask

    task automatic issue_read(input [31:0] addr);
        cmd_addr     = addr;
        cmd_is_write = 1'b0;
        cmd_valid    = 1'b1;
        @(posedge clk);
        while (!cmd_ready) @(posedge clk);
        cmd_valid = 1'b0;
    endtask

    initial begin
        cmd_addr = 0; cmd_wdata = 0; cmd_is_write = 0; cmd_valid = 0;
        resp_ack = 0;
        m_axi_awready = 0; m_axi_wready = 0; m_axi_bvalid = 0; m_axi_bresp = 0;
        m_axi_arready = 0; m_axi_rvalid = 0; m_axi_rresp = 0; m_axi_rdata = 0;

        rst_n = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        // --- Test 1: write transaction completes with OKAY ---
        fork
            issue_write(32'h0000_0004, 32'hDEAD_BEEF);
            respond_okay_write();
        join
        @(posedge clk);
        check("write issues AWVALID/WVALID then completes", resp_valid || resp_axi_status == 2'b00);
        wait (resp_valid);
        check("write response status is OKAY", resp_axi_status == 2'b00);
        resp_ack = 1'b1;
        @(posedge clk);
        resp_ack = 1'b0;

        // --- Test 2: read transaction returns correct data ---
        fork
            issue_read(32'h0000_0100);
            respond_okay_read(32'hCAFEBABE);
        join
        wait (resp_valid);
        check("read response status is OKAY", resp_axi_status == 2'b00);
        check("read data matches slave-provided value", resp_rdata == 32'hCAFEBABE);
        resp_ack = 1'b1;
        @(posedge clk);
        resp_ack = 1'b0;

        // --- Test 3: timeout path (slave never responds to AW) ---
        cmd_addr     = 32'h0000_0200;
        cmd_wdata    = 32'h1234_5678;
        cmd_is_write = 1'b1;
        cmd_valid    = 1'b1;
        @(posedge clk);
        cmd_valid = 1'b0;
        // deliberately never assert m_axi_awready
        wait (resp_valid);
        check("timeout produces an error response", resp_axi_status == 2'b10);
        check("timeout_error flag asserted", timeout_error == 1'b1);
        resp_ack = 1'b1;
        @(posedge clk);
        resp_ack = 1'b0;

        $display("---------------------------------------------------");
        $display("TB_AXI_LITE_MASTER_CMD_IF: %0d passed, %0d failed", pass_count, fail_count);
        if (fail_count == 0) $display("RESULT: ALL TESTS PASSED");
        else $display("RESULT: FAILURES DETECTED");
        $finish;
    end

    initial begin
        #20000;
        $display("[TIMEOUT] Testbench did not finish in time");
        $finish;
    end

endmodule
