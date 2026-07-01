/* ╔══════════════════════════════════════════════════════════════════════════╗
 * ║                            Verilog I2C Testbench                         ║
 * ╠══════════════════════════════════════════════════════════════════════════╣
 * ║  File        : i2c_controller_tb.v                                       ║
 * ║  Name        : Dhanasankar K                                             ║
 * ║  Description : Testbench for I2C master-slave communication              ║
 * ║  Created On  : 2025-07-01                                                ║
 * ╚══════════════════════════════════════════════════════════════════════════╝
 */

`timescale 1ns / 1ps

module i2c_controller_tb;

    // ==============================================================
    // Clock & Reset
    // ==============================================================    
    reg clk;
    reg rst;

    // ==============================================================
    // Master Inputs
    // ==============================================================    
    reg [6:0] addr;
    reg [7:0] data_in;
    reg enable;
    reg rw;

    // ==============================================================
    // Master Outputs
    // ==============================================================    
    wire [7:0] data_out;
    wire ready;

    // ==============================================================
    // Bidirectional I2C lines
    // ==============================================================    
    wire i2c_sda;
    wire i2c_scl;

    // ==============================================================
    // DUT Instantiation
    // ==============================================================    
    i2c_controller master (
        .clk(clk), 
        .rst(rst), 
        .addr(addr), 
        .data_in(data_in), 
        .enable(enable), 
        .rw(rw), 
        .data_out(data_out), 
        .ready(ready), 
        .i2c_sda(i2c_sda), 
        .i2c_scl(i2c_scl)
    );

    // Instantiate all 5 slaves
    i2c_slave_controller1 slave1 (.sda(i2c_sda), .scl(i2c_scl));
    i2c_slave_controller2 slave2 (.sda(i2c_sda), .scl(i2c_scl));
    i2c_slave_controller3 slave3 (.sda(i2c_sda), .scl(i2c_scl));
    i2c_slave_controller4 slave4 (.sda(i2c_sda), .scl(i2c_scl));
    i2c_slave_controller5 slave5 (.sda(i2c_sda), .scl(i2c_scl));

    // Clock Generation
    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    // Main Simulation Sequence
    initial begin
        $dumpfile("i2c.vcd");
        $dumpvars(0, i2c_controller_tb);

        // Reset
        rst = 1; #50; rst = 0;

        // ========== Write to Slave 1 ==========
        $display("Writing to Slave 1 (ADDR: 0x2A)");
        addr = 7'b0101010; data_in = 8'b10101010; rw = 0; enable = 1; #20; enable = 0;
        #250;

        // ========== Read from Slave 1 ==========
        $display("Reading from Slave 1 (ADDR: 0x2A)");
        addr = 7'b0101010; rw = 1; enable = 1; #20; enable = 0;
        #250;
        $display("Read Data from Slave 1: %b", data_out);

        // ========== Write to Slave 2 ==========
        $display("Writing to Slave 2 (ADDR: 0x2B)");
        addr = 7'b0101011; data_in = 8'b11001100; rw = 0; enable = 1; #20; enable = 0;
        #250;

        // ========== Read from Slave 2 ==========
        $display("Reading from Slave 2 (ADDR: 0x2B)");
        addr = 7'b0101011; rw = 1; enable = 1; #20; enable = 0;
        #250;
        $display("Read Data from Slave 2: %b", data_out);

        // ========== Write to Slave 3 ==========
        $display("Writing to Slave 3 (ADDR: 0x2C)");
        addr = 7'b0101100; data_in = 8'b11110000; rw = 0; enable = 1; #20; enable = 0;
        #250;

        // ========== Read from Slave 3 ==========
        $display("Reading from Slave 3 (ADDR: 0x2C)");
        addr = 7'b0101100; rw = 1; enable = 1; #20; enable = 0;
        #250;
        $display("Read Data from Slave 3: %b", data_out);

        // ========== Write to Slave 4 ==========
        $display("Writing to Slave 4 (ADDR: 0x2D)");
        addr = 7'b0101101; data_in = 8'b11110000; rw = 0; enable = 1; #20; enable = 0;
        #250;

        // ========== Read from Slave 4 ==========
        $display("Reading from Slave 4 (ADDR: 0x2D)");
        addr = 7'b0101101; rw = 1; enable = 1; #20; enable = 0;
        #250;
        $display("Read Data from Slave 4: %b", data_out);

        // ========== Write to Slave 5 ==========
        $display("Writing to Slave 5 (ADDR: 0x2F)");
        addr = 7'b0101111; data_in = 8'b11110000; rw = 0; enable = 1; #20; enable = 0;
        #250;

        // ========== Read from Slave 5 ==========
        $display("Reading from Slave 5 (ADDR: 0x2F)");
        addr = 7'b0101111; rw = 1; enable = 1; #20; enable = 0;
        #250;
        $display("Read Data from Slave 5: %b", data_out);

        $display("Simulation completed.");
        $finish;
    end

endmodule
