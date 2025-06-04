1. How many D flip-flops (DFFs) will be inferred from the following Verilog code? 

input c, din; 
output reg y3; 
reg y1, y2; 
 
always @ (posedge c) begin 
  y1 = din; 
  y2 = y1; 
  y3 = y2; 
end 

Answer: 

Only 1 D Flip-Flop will be inferred 
