12. Evaluate the value of x in the below snippet. 

reg [3:0] a; 
reg [1:0] x; 
initial begin 
  a = 4'd10; 
  x = (a >> 1); 
end 

Answer: 

a = 4'd10 → Binary: 1010 

Right shift a >> 1 → 0101 (i.e., 4'd5) 

Now, x is only 2 bits wide, so the result 4'd5 = 0101 will be truncated to fit into 2 bits: 

Only the 2 LSBs of 0101 are retained → 01 
