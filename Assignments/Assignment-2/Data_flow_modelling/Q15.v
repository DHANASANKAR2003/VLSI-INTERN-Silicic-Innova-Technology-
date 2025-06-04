15. Which block executes in the below snippet and justify the reason: 

reg [3:0] a = 4'b110x; 
initial begin 
  if (a !== 4'b1100) begin: B1 
    // block B1 
  end else begin: B2 
    // block B2 
  end 
end 

Answer: 

a = 4'b110x means the least significant bit of a is unknown (x). 

The operator !== in Verilog is the case inequality operator, which considers x and z in the comparison. 

Block B1 executes. 
 Justification: a contains an unknown (x), and the case inequality operator !== treats x as a mismatch, so the condition evaluates to true. 
   
