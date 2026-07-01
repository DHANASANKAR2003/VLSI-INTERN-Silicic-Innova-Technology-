`timescale 1ns/1ps              // Simulation time unit = 1ns, precision = 1ps
`include "interface.sv"         // Include interface file (connects DUT <-> TB)
`include "transaction.sv"       // Transaction class
`include "generator.sv"         // Generator class
`include "driver.sv"            // Driver class
`include "monitor.sv"           // Monitor class
`include "scoreboard.sv"        // Scoreboard class
`include "environment.sv"       // Environment (brings all components together)
`include "test.sv"              // Test class

module top;

    // ============================================================
    // Parameters
    // ============================================================
    parameter data_width = 8;   // FIFO data width
    parameter addr_width = 4;   // FIFO address width (depth = 2^addr_width)

    // ============================================================
    // Clock signals
    // ============================================================
    logic wr_clk = 0;           // Write clock
    logic rd_clk = 0;           // Read clock

    // ============================================================
    // Environment and interface
    // ============================================================
    environment env;            // Testbench environment (generator, driver, monitor, scoreboard)
    fifo_if #(data_width) intf( // Instantiate interface with parameterized data width
        .wr_clk(wr_clk),        // Connect write clock
        .rd_clk(rd_clk)         // Connect read clock
    );

    // ============================================================
    // Clock generation
    // ============================================================
    always #5 wr_clk = ~wr_clk; // Write clock toggles every 5ns → 100 MHz
    always #7 rd_clk = ~rd_clk; // Read clock toggles every 7ns → ~71 MHz (async FIFO!)

    // ============================================================
    // DUT instantiation
    // ============================================================
    async_fifo #(                // Instantiate FIFO DUT
        .data_width(data_width), // Set data width
        .addr_width(addr_width)  // Set address width
    ) dut (
        .data_in(intf.data_in),  // Connect write data
        .wr_en(intf.wr_en),      // Write enable
        .wr_clk(intf.wr_clk),    // Write clock
        .wr_rst(intf.wr_rst),    // Write reset
        .full(intf.full),        // FIFO full flag
        .data_out(intf.data_out),// Read data output
        .rd_en(intf.rd_en),      // Read enable
        .rd_clk(intf.rd_clk),    // Read clock
        .rd_rst(intf.rd_rst),    // Read reset
        .empty(intf.empty)       // FIFO empty flag
    );

    // ============================================================
    // VCD dump for waveform
    // ============================================================
    initial begin
        $dumpfile("fifo.vcd");   // VCD file for GTKWave
        $dumpvars(0, top);       // Dump all signals in top module
    end

    // ============================================================
    // Run test program
    // ============================================================
    test tst(intf);              // Instantiate and run test, passing interface

endmodule
