10. Find the output for the below codes: 

reg a, b; 
always@(a, b) begin 
  #10 a <= 1'b0; 
  #1  b <= 1'b1; 
  a <= 1; 
  #5  b <= a; 
  $display($time,"a=%d,b=%d",a,b); 
end 
reg a, b; 
always@(a, b) begin 
  #10 a = 1'b0; 
  #1  b = 1'b1; 
  a = 1; 
  #5  b = a; 
  $display($time,"a=%d,b=%d",a,b); 
end 
reg a, b; 
initial begin 
  a = 1; 
  b = a; 
  $display($time,"a=%d,b=%d",a,b); 
end
initial begin 
  #1 a <= 1; 
  b <= a; 
  $display($time,"a=%d,b=%d",a,b); 
end
Code 

Time 

Output 

1 

16 

Unpredictable or x, depends on sim 

2 

16 

a = 1, b = 1 

3 

0 

a = 1, b = 1 

 

1 

a = 1, b = 1 

