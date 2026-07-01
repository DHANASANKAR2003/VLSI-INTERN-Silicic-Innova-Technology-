18. What is the value of b in the below expression and justify the reason: 

reg [3:0] a = 4'b0100; 
reg [3:0] b; 
 
initial begin 
  b = a + 1'bx; 
end 
Answer: 

Justification: 

Any arithmetic operation involving an x (unknown) will propagate uncertainty across the result. 
 Since 1'bx is not a known value (either 0 or 1), the simulator cannot resolve the addition precisely, resulting in: 

b = 4'bxxxx 
