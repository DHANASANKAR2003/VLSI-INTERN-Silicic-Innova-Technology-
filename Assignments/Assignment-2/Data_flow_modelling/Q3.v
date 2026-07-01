3. What value is passed across the port b in the below Verilog snippet? 

module test(output [32:0] b); 
    real a = 14.5; 
    assign b = a; 
endmodule 

Answer: 

real is used to represent floating-point values. 

b is a 33-bit vector of type wire (i.e., integer or bit-based). 

Assigning a real value (a = 14.5) to a vector like b causes type conversion. 

Result: 
Only the integer part of the real number is assigned. So: 

a = 14.5  →  b = 14 (binary) 

14 in binary = 0000000000000000000000000000001110 
