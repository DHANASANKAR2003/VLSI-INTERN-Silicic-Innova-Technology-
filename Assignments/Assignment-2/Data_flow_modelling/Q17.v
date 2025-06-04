17. What is the value of y in the below expression and justify the reason? 

reg [3:0] a = 4'b010x; 
wire y = (a == 4'b1100) ? 1'b1 : 1'b0; 

Answer: 

Justification: 

The MSB of a is 0 and does not match with the MSB of 4'b1100 which is 1. 
 Since this is a definite mismatch, the expression (a == 4'b1100) evaluates to 0, and hence: 

y = 1'b0 
