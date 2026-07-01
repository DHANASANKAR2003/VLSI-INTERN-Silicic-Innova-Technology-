5. Which hardware logic is inferred from the below snippet? 

always @(*) begin 
  case (1'b1) 
    a[3]: y = 3; 
    a[2]: y = 2; 
    a[1]: y = 1; 
    a[0]: y = 0; 
  endcase 
end 

Answer: 

Priority Encoder (4-to-2) 
 The case (1'b1) structure with conditions like a[3]:, a[2]:, etc., forms a priority encoder that gives priority to higher bits in a[3:0]. 
