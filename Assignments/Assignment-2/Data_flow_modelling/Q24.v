24. What value will be displayed for acc at the end of the code execution? 
reg [3:0] acc; 
initial begin
  acc = 4'b0001;                  // acc = 1 
  while (acc < 4'b1000) begin     // loop until acc < 8 
    acc = acc + 1; 
  end 
  $display("acc = %b", acc); 
end 

Answer: 
acc = 1000 
