14. Initial value of a=1 and b=2, then what will be final value if 

always @(posedge clock) 
  a <= b; 
 
always @(posedge clock) 
  b <= a; 

Final Values After One Clock Edge: 

a = 2 

b = 1 
