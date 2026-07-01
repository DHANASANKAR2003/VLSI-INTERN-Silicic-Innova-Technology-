// tb_axi_lite_protocol_checker.sv
// Testbench for axi_lite_protocol_checker.v
// Drives the five AXI-Lite channel signals directly (no DUT-under-test bus
// master needed - this checker is purely a passive observer) and verifies:
//   1. Clean, well-behaved handshakes produce no violation.
//   2. A channel that drops VALID before READY arrives is correctly flagged.
//   3. A long stall on AWVALID/ARVALID raises stall_warning.

`timescale 1ns/1ps

module tb_axi_lite_protocol_checker;

    localparam CLK_PERIOD = 10;

    reg clk = 0;
    reg rst_n = 0;

    reg awvalid, awready, wvalid, wready, bvalid, bready;
    reg arvalid, arready, rvalid, rready;

    wire violation_pulse, violation_latched, stall_warning;

    integer pass_count = 0;
    integer fail_count = 0;

    axi_lite_protocol_checker #(
        .STALL_LIMIT(20)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .awvalid(awvalid), .awready(awready),
        .wvalid(wvalid),   .wready(wready),
        .bvalid(bvalid),   .bready(bready),
        .arvalid(arvalid), .arready(arready),
        .rvalid(rvalid),   .rready(rready),
        .violation_pulse(violation_pulse),
        .violation_latched(violation_latched),
        .stall_warning(stall_warning)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    task check(string name, logic cond);
        if (cond) begin pass_count++; $display("[PASS] %s", name); end
        else begin fail_count++; $display("[FAIL] %s", name); end
    endtask

    task automatic clear_all();
        awvalid = 0; awready = 0; wvalid = 0; wready = 0; bvalid = 0; bready = 0;
        arvalid = 0; arready = 0; rvalid = 0; rready = 0;
    endtask

    initial begin
        clear_all();
        rst_n = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        // ---- Test 1: clean handshake, VALID and READY together, no violation ----
        @(posedge clk);
        awvalid = 1; awready = 1;
        @(posedge clk);
        awvalid = 0; awready = 0;
        @(posedge clk);
        check("clean immediate handshake produces no violation", violation_latched == 1'b0);

        // ---- Test 2: VALID held while waiting for READY (legal), then completes ----
        @(posedge clk);
        arvalid = 1; arready = 0;
        repeat (3) @(posedge clk); // master correctly holds ARVALID high while waiting
        arready = 1;
        @(posedge clk);
        arvalid = 0; arready = 0;
        @(posedge clk);
        check("holding VALID while waiting for READY is legal (no violation)", violation_latched == 1'b0);

        // ---- Test 3: illegal VALID drop before READY (protocol violation) ----
        @(posedge clk);
        wvalid = 1; wready = 0;
        @(posedge clk);
        wvalid = 0; // ILLEGAL: dropping VALID without READY ever having been seen
        @(posedge clk);
        check("dropping VALID before READY raises a violation pulse", violation_pulse == 1'b1 || violation_latched == 1'b1);
        check("violation_latched stays set (sticky)", violation_latched == 1'b1);

        // ---- Test 4: stall warning after long AWVALID stall ----
        clear_all();
        rst_n = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        awvalid = 1; awready = 0;
        repeat (25) @(posedge clk); // exceed STALL_LIMIT=20
        check("long AW stall raises stall_warning", stall_warning == 1'b1);
        awvalid = 0;

        $display("---------------------------------------------------");
        $display("TB_AXI_LITE_PROTOCOL_CHECKER: %0d passed, %0d failed", pass_count, fail_count);
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
