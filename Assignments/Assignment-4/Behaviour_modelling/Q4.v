4. Which of the statements will execute from the below snippet & justify the behavior? 

reg c = 3'b00x; 
always @(*) begin 
  casex(c) 
    3'b000: st1; 
    3'b100: st2; 
    3'b001: st3; 
  endcase 
end 

Justification: 
casex allows x to be treated as a wildcard. 

Since c = 3'b00x matches both 3'b000 and 3'b001, the first one listed in the casex block (3'b000) is executed. 

Output: 
The first match in order is 3'b000: st1; 

So st1 will execute. 
