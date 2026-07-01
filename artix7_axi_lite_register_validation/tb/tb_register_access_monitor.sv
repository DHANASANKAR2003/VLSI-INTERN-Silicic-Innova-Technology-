// tb_register_access_monitor.sv
// Testbench for register_access_monitor.v
// Drives a handful of write/read transactions (some clean, some erroring)
// directly on the monitor's observed inputs and checks its counters and
// address-history shift register update correctly.

`timescale 1ns/1ps

module tb_register_access_monitor;

    localparam CLK_PERIOD = 10;

    reg clk = 0;
    reg rst_n = 0;

    reg  [31:0] awaddr;
    reg         awvalid, awready;
    reg         bvalid, bready;
    reg  [1:0]  bresp;
    reg  [31:0] araddr;
    reg         arvalid, arready;
    reg         rvalid, rready;
    reg  [1:0]  rresp;

    wire [31:0] write_count, read_count, error_count, last_addr_accessed;

    integer pass_count = 0;
    integer fail_count = 0;

    register_access_monitor #(
        .HIST_DEPTH(8)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .awaddr(awaddr), .awvalid(awvalid), .awready(awready),
        .bvalid(bvalid), .bready(bready), .bresp(bresp),
        .araddr(araddr), .arvalid(arvalid), .arready(arready),
        .rvalid(rvalid), .rready(rready), .rresp(rresp),
        .write_count(write_count), .read_count(read_count), .error_count(error_count),
        .last_addr_accessed(last_addr_accessed)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    task check(string name, logic cond);
        if (cond) begin pass_count++; $display("[PASS] %s", name); end
        else begin fail_count++; $display("[FAIL] %s", name); end
    endtask

    task automatic do_write(input [31:0] addr, input [1:0] resp);
        @(posedge clk);
        awaddr = addr; awvalid = 1; awready = 1;
        @(posedge clk);
        awvalid = 0; awready = 0;
        bvalid = 1; bready = 1; bresp = resp;
        @(posedge clk);
        bvalid = 0; bready = 0;
    endtask

    task automatic do_read(input [31:0] addr, input [1:0] resp);
        @(posedge clk);
        araddr = addr; arvalid = 1; arready = 1;
        @(posedge clk);
        arvalid = 0; arready = 0;
        rvalid = 1; rready = 1; rresp = resp;
        @(posedge clk);
        rvalid = 0; rready = 0;
    endtask

    initial begin
        awaddr=0; awvalid=0; awready=0; bvalid=0; bready=0; bresp=0;
        araddr=0; arvalid=0; arready=0; rvalid=0; rready=0; rresp=0;

        rst_n = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        check("write_count starts at 0", write_count == 32'd0);
        check("read_count starts at 0", read_count == 32'd0);
        check("error_count starts at 0", error_count == 32'd0);

        do_write(32'h0000_0010, 2'b00); // OKAY
        check("write_count increments on clean write", write_count == 32'd1);
        check("error_count stays 0 after clean write", error_count == 32'd0);
        check("last_addr_accessed updated to write address", last_addr_accessed == 32'h0000_0010);

        do_read(32'h0000_0100, 2'b00); // OKAY
        check("read_count increments on clean read", read_count == 32'd1);
        check("last_addr_accessed updated to read address", last_addr_accessed == 32'h0000_0100);

        do_write(32'h0000_0300, 2'b11); // DECERR
        check("write_count still increments even on error response", write_count == 32'd2);
        check("error_count increments on DECERR write", error_count == 32'd1);

        do_read(32'h0000_0304, 2'b10); // SLVERR
        check("read_count still increments even on error response", read_count == 32'd2);
        check("error_count increments on SLVERR read", error_count == 32'd2);

        // Address history check: most recent access should be at index 0
        do_write(32'hDEAD_0000, 2'b00);
        check("address history index 0 holds most recent address", dut.debug_addr_hist[0] == 32'hDEAD_0000);

        $display("---------------------------------------------------");
        $display("TB_REGISTER_ACCESS_MONITOR: %0d passed, %0d failed", pass_count, fail_count);
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
