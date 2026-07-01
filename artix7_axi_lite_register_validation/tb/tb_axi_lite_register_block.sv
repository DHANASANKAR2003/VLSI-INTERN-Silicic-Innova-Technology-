// tb_axi_lite_register_block.sv
// Testbench for axi_lite_register_block.v
// Covers exactly the test categories from the project's validation plan:
// reset value check, RW/RO/WO access policy check, and bit-bash on RW fields.

`timescale 1ns/1ps

module tb_axi_lite_register_block;

    localparam CLK_PERIOD = 10;

    reg clk = 0;
    reg rst_n = 0;

    reg  [31:0] s_axi_awaddr;
    reg         s_axi_awvalid;
    wire        s_axi_awready;
    reg  [31:0] s_axi_wdata;
    reg  [3:0]  s_axi_wstrb;
    reg         s_axi_wvalid;
    wire        s_axi_wready;
    wire [1:0]  s_axi_bresp;
    wire        s_axi_bvalid;
    reg         s_axi_bready;
    reg  [31:0] s_axi_araddr;
    reg         s_axi_arvalid;
    wire        s_axi_arready;
    wire [31:0] s_axi_rdata;
    wire [1:0]  s_axi_rresp;
    wire        s_axi_rvalid;
    reg         s_axi_rready;

    wire [31:0] reg0_out, reg1_out, reg2_out, reg3_out;
    reg  [31:0] reg1_status_in;
    reg         reg1_status_load;

    integer pass_count = 0;
    integer fail_count = 0;

    // Policy: reg0=RW, reg1=RO, reg2=WO, reg3=RW
    localparam [7:0] TEST_POLICY = 8'b00_10_01_00;

    axi_lite_register_block #(
        .RESET_VAL0(32'hA5A5_0001),
        .RESET_VAL1(32'h0000_0000),
        .RESET_VAL2(32'h0000_0000),
        .RESET_VAL3(32'h0000_0000),
        .ACCESS_POLICY(TEST_POLICY)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .s_axi_awaddr(s_axi_awaddr), .s_axi_awvalid(s_axi_awvalid), .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata), .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid), .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp), .s_axi_bvalid(s_axi_bvalid), .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr), .s_axi_arvalid(s_axi_arvalid), .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata), .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid), .s_axi_rready(s_axi_rready),
        .reg0_out(reg0_out), .reg1_out(reg1_out), .reg2_out(reg2_out), .reg3_out(reg3_out),
        .reg1_status_in(reg1_status_in), .reg1_status_load(reg1_status_load)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    task check(string name, logic cond);
        if (cond) begin pass_count++; $display("[PASS] %s", name); end
        else begin fail_count++; $display("[FAIL] %s", name); end
    endtask

    task automatic axi_write(input [31:0] addr, input [31:0] data, output [1:0] bresp_out);
        @(posedge clk);
        s_axi_awaddr  = addr;
        s_axi_awvalid = 1'b1;
        s_axi_wdata   = data;
        s_axi_wstrb   = 4'hF;
        s_axi_wvalid  = 1'b1;
        @(posedge clk);
        while (!(s_axi_awready && s_axi_wready)) @(posedge clk);
        s_axi_awvalid = 1'b0;
        s_axi_wvalid  = 1'b0;
        s_axi_bready  = 1'b1;
        @(posedge clk);
        while (!s_axi_bvalid) @(posedge clk);
        bresp_out = s_axi_bresp;
        @(posedge clk);
        s_axi_bready = 1'b0;
    endtask

    task automatic axi_read(input [31:0] addr, output [31:0] data_out, output [1:0] rresp_out);
        @(posedge clk);
        s_axi_araddr  = addr;
        s_axi_arvalid = 1'b1;
        @(posedge clk);
        while (!s_axi_arready) @(posedge clk);
        s_axi_arvalid = 1'b0;
        s_axi_rready  = 1'b1;
        @(posedge clk);
        while (!s_axi_rvalid) @(posedge clk);
        data_out  = s_axi_rdata;
        rresp_out = s_axi_rresp;
        @(posedge clk);
        s_axi_rready = 1'b0;
    endtask

    reg  [31:0] rdata;
    reg  [1:0]  bresp, rresp;
    integer     bit_i;

    initial begin
        s_axi_awaddr = 0; s_axi_awvalid = 0; s_axi_wdata = 0; s_axi_wstrb = 0; s_axi_wvalid = 0;
        s_axi_bready = 0; s_axi_araddr = 0; s_axi_arvalid = 0; s_axi_rready = 0;
        reg1_status_in = 0; reg1_status_load = 0;

        rst_n = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        // ---- Test: reset values ----
        check("reg0 resets to RESET_VAL0", reg0_out == 32'hA5A5_0001);
        check("reg1 resets to 0", reg1_out == 32'h0000_0000);
        check("reg2 resets to 0", reg2_out == 32'h0000_0000);
        check("reg3 resets to 0", reg3_out == 32'h0000_0000);

        // ---- Test: RW register (reg0) write then read back ----
        axi_write(32'h0000_0000, 32'h1111_2222, bresp);
        check("RW write to reg0 returns OKAY", bresp == 2'b00);
        axi_read(32'h0000_0000, rdata, rresp);
        check("RW readback matches written value", rdata == 32'h1111_2222);

        // ---- Test: RO register (reg1) - write should be silently ignored ----
        axi_write(32'h0000_0004, 32'hFFFF_FFFF, bresp);
        check("write to RO register still gets OKAY (not a bus error)", bresp == 2'b00);
        axi_read(32'h0000_0004, rdata, rresp);
        check("RO register value unchanged by write attempt", rdata == 32'h0000_0000);

        // RO register reflects externally-loaded status
        reg1_status_in   = 32'hBEEF_0000;
        reg1_status_load = 1'b1;
        @(posedge clk);
        reg1_status_load = 1'b0;
        axi_read(32'h0000_0004, rdata, rresp);
        check("RO register reflects externally loaded status value", rdata == 32'hBEEF_0000);

        // ---- Test: WO register (reg2) - write succeeds, read always returns 0 ----
        axi_write(32'h0000_0008, 32'hABCD_EF01, bresp);
        check("write to WO register returns OKAY", bresp == 2'b00);
        axi_read(32'h0000_0008, rdata, rresp);
        check("WO register always reads back as 0", rdata == 32'h0000_0000);

        // ---- Test: bit-bash on RW register (reg3) - walking ones ----
        for (bit_i = 0; bit_i < 32; bit_i = bit_i + 1) begin
            axi_write(32'h0000_000C, (32'h1 << bit_i), bresp);
            axi_read(32'h0000_000C, rdata, rresp);
            check($sformatf("bit-bash reg3 bit %0d set/readback", bit_i), rdata == (32'h1 << bit_i));
        end

        // ---- Test: bit-bash on RW register (reg3) - walking zeros ----
        for (bit_i = 0; bit_i < 32; bit_i = bit_i + 1) begin
            axi_write(32'h0000_000C, ~(32'h1 << bit_i), bresp);
            axi_read(32'h0000_000C, rdata, rresp);
            check($sformatf("bit-bash reg3 bit %0d clear/readback", bit_i), rdata == ~(32'h1 << bit_i));
        end

        $display("---------------------------------------------------");
        $display("TB_AXI_LITE_REGISTER_BLOCK: %0d passed, %0d failed", pass_count, fail_count);
        if (fail_count == 0) $display("RESULT: ALL TESTS PASSED");
        else $display("RESULT: FAILURES DETECTED");
        $finish;
    end

    initial begin
        #200000;
        $display("[TIMEOUT] Testbench did not finish in time");
        $finish;
    end

endmodule
