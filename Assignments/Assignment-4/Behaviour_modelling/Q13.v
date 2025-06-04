13. What will be the value of q in the following code? 

reg q, d, clk; 
always @(posedge clk) begin 
  #20 q = d; 
end 
initial begin 
  clk = 0; 
  d = 1; 
  #25 clk 1; 
end 
initial 
  $display("q = %b", q); 

 

Output 

q = 1 
