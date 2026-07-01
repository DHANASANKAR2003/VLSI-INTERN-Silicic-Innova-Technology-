23. What will be the final value of i and sum after the loop finishes executing? 

reg [3:0] sum; 

integer i; 

initial begin 

  sum = 4'b0000;        // sum = 0 

  for (i = 0; i < 4; i = i + 1) begin 

    sum = sum + i; 

  end 

  $display("i = %0d, sum = %b", i, sum); 

end 

 

Answer: 

i = 4, sum = 0110 

 
