22. What will be the value of x after executing the code? Justify your answer. 

reg [3:0] x; 

initial begin 

  x = 4'b0011;    // x = 3 

  fork 

    #5  x = x + 1; 

    #10 x = x + 2; 

  join 

end 

 

Answer: 

x = 6 (4'b0110) at the end of execution. 

Justification: 

Due to parallel execution in the fork...join, each assignment uses the value of x as it exists at the time of execution, leading to sequentially updated values: 

First update at 5 ns: x = 4 

Second update at 10 ns: x = 6 

 
