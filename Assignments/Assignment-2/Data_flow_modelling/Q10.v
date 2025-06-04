10. What is the value of x in the below snippet? 

reg [2:0] a, b; 
reg [2:0] x; 
initial 
begin 
  a = 3'd5; 
  b = 3'b111; 
  x = a | b; 
end 

Answer: 

a = 3'd5 → Binary: 101 

b = 3'b111 → Binary: 111 

x = 3'b111 or x = 7
