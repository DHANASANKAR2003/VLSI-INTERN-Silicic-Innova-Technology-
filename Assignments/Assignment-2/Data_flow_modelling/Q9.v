9. What is the value of y in the below snippet? 

reg [2:0] a, b; 
reg y; 
initial 
begin 
  a = 3'd5; 
  b = 3'b111; 
  y = a && b; 
end 

Answer: 
a = 3'd5; → Binary: 101 
b = 3'b111; → Binary: 111

In Verilog, the && operator is a logical AND (not bitwise). 
 So, a && b evaluates to: 
1 if both a and b are non-zero 
0 if either is 0 
Since both a and b are non-zero values, the result is: 

y = 1 
