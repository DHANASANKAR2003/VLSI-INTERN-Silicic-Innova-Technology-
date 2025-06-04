13. Find the value of b in the below snippet. 

reg [3:0] a; 
reg [6:0] b; 
initial begin 
  a = 4'd10; 
  b = {a, 1}; 
end 

Answer: 

a = 4'd10 → Binary: 1010 

The concatenation {a, 1} appends the 1-bit value 1 to the right side of a, resulting in a 5-bit value: 
 {a, 1} = {4'b1010, 1'b1} = 5'b10101 = decimal 21 

But b is 7 bits wide, and we are assigning only 5 bits. So the remaining 2 MSBs will be padded with zeros: 

b = 7'b0010101 = decimal 21 
