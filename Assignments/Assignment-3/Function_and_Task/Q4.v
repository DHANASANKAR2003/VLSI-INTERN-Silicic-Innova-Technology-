4. Write a Verilog code to generate 20 odd or even values using a function. 

`timescale 1ns / 1ps 
module odd_even_generator; 
    function [7:0] get_value; 
        input integer n; 
        input bit even;          
          begin 
            if (even) 
                get_value = 2 * n;            
       else 
                get_value = 2 * n + 1;    
        end 
    endfunction 
    integer i; 
    bit is_even = 1;  

    reg [7:0] val; 
    initial begin 
        $display("Generating 20 %s numbers:", is_even ? "even" : "odd"); 
        for (i = 0; i < 20; i = i + 1) begin 
            val = get_value(i, is_even); 
            $display("Value %0d = %0d", i, val); 
        end 
        $finish; 
    end 
endmodule 

`timescale 1ns / 1ps 
module tb_odd_even_generator; 
    odd_even_generator dut(); 
endmodule 
  
OUTPUT 

Generating 20 odd numbers: 
Value 0 = 1 
Value 1 = 3 
Value 2 = 5 
Value 3 = 7 
Value 4 = 9 
Value 5 = 11 
Value 6 = 13 
Value 7 = 15 
Value 8 = 17 
Value 9 = 19 
Value 10 = 21 
Value 11 = 23 
Value 12 = 25 
Value 13 = 27 
Value 14 = 29 
Value 15 = 31 
Value 16 = 33 
Value 17 = 35 
Value 18 = 37 
Value 19 = 39 
design.sv:25: $finish called at 0 (1ps) 

Generating 20 even numbers: 
Value 0 = 0 
Value 1 = 2 
Value 2 = 4 
Value 3 = 6 
Value 4 = 8 
Value 5 = 10 
Value 6 = 12 
Value 7 = 14 
Value 8 = 16 
Value 9 = 18 
Value 10 = 20 
Value 11 = 22 
Value 12 = 24 
Value 13 = 26 
Value 14 = 28 
Value 15 = 30 
Value 16 = 32 
Value 17 = 34 
Value 18 = 36 
Value 19 = 38 
design.sv:25: $finish called at 0 (1ps) 
