1. What will be the output of the code?  

module task_example_nonblocking;  
reg [7:0] a, b, c;  
reg [7:0] sum;
// Task to calculate sum using blocking assignment task  
calculate_sum;  
input [7:0] x, y, z;  
output [7:0] total;  
begin total = x + y + z;  
end endtask 
initial begin  
a = 5;  
b = 10;  
c = 15;  
calculate_sum(a, b, c, sum);  
$display("Sum: %d", sum);  
end  
endmodule 

Answer: 
Output: 

Sum: 30 
