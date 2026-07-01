16. What is the value of y in the below expression and justify the reason? 

reg [3:0] a = 4'b110x; 
wire y = (a == 4'b1100) ? 1'b1 : 1'b0; 

Answer: 

a = 4'b110x means: 

a[3] = 1, a[2] = 1, a[1] = 0, a[0] = x (unknown value). 

The operator == in Verilog is the logical equality operator, which returns x (unknown) if any operand bit is unknown (x or z). 

y = x 
