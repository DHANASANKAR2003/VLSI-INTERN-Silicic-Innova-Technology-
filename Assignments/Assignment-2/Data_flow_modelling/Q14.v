14. Which block executes in the below snippet and justify the reason: 

reg [3:0] a = 4'b110x; 
initial begin 
  if (a == 4'b1100) begin: B1 
    // block B1 
  end else begin: B2 
    // block B2 
  end 
end 

Answer: 

a = 4'b110x means the least significant bit (LSB) of a is unknown (x). 

So a = 4'b110x is not equal to 4'b1100 because x ≠ 0 or x ≠ 1. 

If any bit in the comparison is x or z, then the comparison result is x (unknown). 

The if condition evaluates an x as false. 

Block B2 executes. 
 Because a = 4'b110x contains an unknown bit, the condition a == 4'b1100 evaluates to false, and the else block (B2) is executed. 
