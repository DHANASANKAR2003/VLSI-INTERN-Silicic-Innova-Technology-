// tb_axi_lite_error_injector.sv
// Testbench for axi_lite_error_injector.v
// Verifies each of the four injection modes independently, and verifies
// clean passthrough behavior when no injection is active.

`timescale 1ns/1ps

module tb_axi_lite_error_injector;

    localparam CLK_PERIOD = 10;

    reg clk = 0;
    reg rst_n = 0;

    reg  [3:0] inject_ctrl;
    reg        inject_ctrl_wr;

    reg  [31:0] up_awaddr;
    reg         up_awvalid;
    wire        up_awready;
    reg  [31:0] up_wdata;
    reg  [3:0]  up_wstrb;
    reg         up_wvalid;
    wire        up_wready;
    wire [1:0]  up_bresp;
    wire        up_bvalid;
    reg         up_bready;
    reg  [31:0] up_araddr;
    reg         up_arvalid;
    wire        up_arready;
    wire [31:0] up_rdata;
    wire [1:0]  up_rresp;
    wire        up_rvalid;
    reg         up_rready;

    wire [31:0] dn_awaddr;
    wire        dn_awvalid;
    reg         dn_awready;
    wire [31:0] dn_wdata;
    wire [3:0]  dn_wstrb;
    wire        dn_wvalid;
    reg         dn_wready;
    reg  [1:0]  dn_bresp;
    reg         dn_bvalid;
    wire        dn_bready;
    wire [31:0] dn_araddr;
    wire        dn_arvalid;
    reg         dn_arready;
    reg  [31:0] dn_rdata;
    reg  [1:0]  dn_rresp;
    reg         dn_rvalid;
    wire        dn_rready;

    integer pass_count = 0;
    integer fail_count = 0;

    axi_lite_error_injector #(
        .EXTRA_WAIT_CYCLES(10)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .inject_ctrl(inject_ctrl), .inject_ctrl_wr(inject_ctrl_wr),
        .up_awaddr(up_awaddr), .up_awvalid(up_awvalid), .up_awready(up_awready),
        .up_wdata(up_wdata), .up_wstrb(up_wstrb), .up_wvalid(up_wvalid), .up_wready(up_wready),
        .up_bresp(up_bresp), .up_bvalid(up_bvalid), .up_bready(up_bready),
        .up_araddr(up_araddr), .up_arvalid(up_arvalid), .up_arready(up_arready),
        .up_rdata(up_rdata), .up_rresp(up_rresp), .up_rvalid(up_rvalid), .up_rready(up_rready),
        .dn_awaddr(dn_awaddr), .dn_awvalid(dn_awvalid), .dn_awready(dn_awready),
        .dn_wdata(dn_wdata), .dn_wstrb(dn_wstrb), .dn_wvalid(dn_wvalid), .dn_wready(dn_wready),
        .dn_bresp(dn_bresp), .dn_bvalid(dn_bvalid), .dn_bready(dn_bready),
        .dn_araddr(dn_araddr), .dn_arvalid(dn_arvalid), .dn_arready(dn_arready),
        .dn_rdata(dn_rdata), .dn_rresp(dn_rresp), .dn_rvalid(dn_rvalid), .dn_rready(dn_rready)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    task check(string name, logic cond);
        if (cond) begin pass_count++; $display("[PASS] %s", name); end
        else begin fail_count++; $display("[FAIL] %s", name); end
    endtask

    initial begin
        inject_ctrl = 4'b0000; inject_ctrl_wr = 0;
        up_awaddr = 0; up_awvalid = 0; up_wdata = 0; up_wstrb = 4'hF; up_wvalid = 0; up_bready = 0;
        up_araddr = 0; up_arvalid = 0; up_rready = 0;
        dn_awready = 0; dn_wready = 0; dn_bvalid = 0; dn_bresp = 0;
        dn_arready = 0; dn_rvalid = 0; dn_rresp = 0; dn_rdata = 0;

        rst_n = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        // ---- Test 1: clean passthrough, no injection ----
        @(posedge clk);
        up_awaddr = 32'h0000_0040; up_awvalid = 1'b1;
        up_wdata  = 32'hAAAA_5555; up_wvalid  = 1'b1;
        dn_awready = 1'b1; dn_wready = 1'b1;
        @(posedge clk);
        check("AW passthrough address matches", dn_awaddr == 32'h0000_0040);
        check("W passthrough data matches", dn_wdata == 32'hAAAA_5555);
        up_awvalid = 0; up_wvalid = 0; dn_awready = 0; dn_wready = 0;
        dn_bvalid = 1'b1; dn_bresp = 2'b00; up_bready = 1'b1;
        @(posedge clk);
        check("clean write response passes through as OKAY", up_bresp == 2'b00 && up_bvalid);
        dn_bvalid = 0; up_bready = 0;

        // ---- Test 2: force DECERR on write response ----
        inject_ctrl = 4'b0001; inject_ctrl_wr = 1'b1; // bit0 = force DECERR
        @(posedge clk);
        inject_ctrl_wr = 1'b0;
        up_bready = 1'b1;
        @(posedge clk);
        check("forced DECERR appears on up_bresp", up_bresp == 2'b11);
        check("up_bvalid asserted for the forced error response", up_bvalid == 1'b1);
        up_bready = 0;

        // ---- Test 3: force SLVERR on read response ----
        inject_ctrl = 4'b0010; inject_ctrl_wr = 1'b1; // bit1 = force SLVERR
        @(posedge clk);
        inject_ctrl_wr = 1'b0;
        up_rready = 1'b1;
        @(posedge clk);
        check("forced SLVERR appears on up_rresp", up_rresp == 2'b10);
        check("forced-error read data is zero", up_rdata == 32'h0000_0000);
        up_rready = 0;

        // ---- Test 4: corrupt read data ----
        inject_ctrl = 4'b1000; inject_ctrl_wr = 1'b1; // bit3 = corrupt RDATA
        @(posedge clk);
        inject_ctrl_wr = 1'b0;
        dn_rvalid = 1'b1; dn_rresp = 2'b00; dn_rdata = 32'h1234_5678;
        up_rready = 1'b1;
        @(posedge clk);
        check("corrupted read data is bitwise inverted", up_rdata == ~32'h1234_5678);
        dn_rvalid = 0; up_rready = 0;

        // ---- Test 5: hold AW (timeout-injection path) ----
        inject_ctrl = 4'b0100; inject_ctrl_wr = 1'b1; // bit2 = hold AW
        @(posedge clk);
        inject_ctrl_wr = 1'b0;
        up_awaddr = 32'h0000_0080; up_awvalid = 1'b1;
        dn_awready = 1'b1; // downstream WOULD accept immediately, but injector should hold
        @(posedge clk);
        check("AW held: dn_awvalid suppressed while hold_aw active", dn_awvalid == 1'b0);
        repeat (12) @(posedge clk); // wait past EXTRA_WAIT_CYCLES=10
        check("AW eventually passes through after hold expires", dn_awvalid == 1'b1 || up_awready == 1'b1);
        up_awvalid = 0; dn_awready = 0;

        $display("---------------------------------------------------");
        $display("TB_AXI_LITE_ERROR_INJECTOR: %0d passed, %0d failed", pass_count, fail_count);
        if (fail_count == 0) $display("RESULT: ALL TESTS PASSED");
        else $display("RESULT: FAILURES DETECTED");
        $finish;
    end

    initial begin
        #50000;
        $display("[TIMEOUT] Testbench did not finish in time");
        $finish;
    end

endmodule
