5. Write a Verilog code to create two functions for multiplication and division. 
 
module math_functions ( 
    input [7:0] a, b, 
    output [15:0] product, 
    output [7:0] quotient 
); 
    // Function for multiplication 
    function [15:0] multiply; 
        input [7:0] x, y; 
        begin 
            multiply = x * y; 
        end 
    endfunction 
 
    // Function for division 
    function [7:0] divide; 
        input [7:0] x, y; 
        begin 
            if (y != 0) 
                divide = x / y; 
            else 
                divide = 8'd0; // To avoid divide-by-zero 
        end 
    endfunction 
 
    assign product = multiply(a, b); 
    assign quotient = divide(a, b); 
endmodule 

 
`timescale 1ns / 1ps 
module tb_math_functions; 
    reg [7:0] a, b; 
    wire [15:0] product; 
    wire [7:0] quotient; 
    // Instantiate the DUT (Device Under Test) 
    math_functions dut ( 
        .a(a), 
        .b(b), 
        .product(product), 
        .quotient(quotient) 
    ); 
    initial begin 
        a = 8'd12; 
        b = 8'd4; 
        #10; 
 
        $display("a = %d, b = %d", a, b); 
        $display("Multiplication = %d", product); 
        $display("Division = %d", quotient); 
        a = 8'd100; 
        b = 8'd20; 
        #10; 
        $display("a = %d, b = %d", a, b); 
        $display("Multiplication = %d", product); 
        $display("Division = %d", quotient); 
        a = 8'd50; 
        b = 8'd0; 
        #10; 
        $display("a = %d, b = %d", a, b); 
        $display("Multiplication = %d", product); 
        $display("Division (should be 0 to avoid error) = %d", quotient); 
        $finish; 
    end 
endmodule 
 
OUTPUT: 

a = 12, b = 4 
Multiplication = 48 
Division = 3 
a = 100, b = 20 
Multiplication = 2000 
Division = 5 
a = 50, b = 0 
Multiplication = 0 
Division (should be 0 to avoid error) = 0 
testbench.sv:45: $finish called at 30000 (1ps) 
