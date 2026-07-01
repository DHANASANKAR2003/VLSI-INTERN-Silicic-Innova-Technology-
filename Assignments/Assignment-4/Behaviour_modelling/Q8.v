8, Draw the waveform for the below snippet. 

initial 
begin 
  #5 clk = 0; 
  forever #5 clk = ~clk; 
end 
 
initial 
begin 
  rst = 1; 
  repeat(3) @(negedge clk); 
  rst = 0; 
end 

 

Picture 
