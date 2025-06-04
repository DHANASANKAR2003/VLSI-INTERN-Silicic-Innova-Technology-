11. What is the value of x in the below snippet? 

reg [2:0] a; 
reg [2:0] x; 
initial begin 
  a = 3'd4; 
  x = ^a; 
end 

Answer: 

a = 3'd4 → Binary: 100 

^a → Reduction XOR of all bits of a 

^a = 1 ^ 0 ^ 0 = 1 

So, x = 1, which means: 

x = 3'b001 (only LSB is 1) 
