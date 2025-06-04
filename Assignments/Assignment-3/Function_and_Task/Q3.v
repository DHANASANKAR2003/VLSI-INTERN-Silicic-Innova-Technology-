3. Write a Verilog code to perform the sum of two numbers using a task. 
  
module task_sum; 
// Declare variables reg [7:0] a, b; reg [7:0] result; 
 task add_two_numbers;  
input [7:0] x, y;  
output [7:0] sum;  
begin  
sum = x + y;  
end  
endtask 
initial begin  
 a = 8'd15; b = 8'd25;  
add_two_numbers(a, b, result);  
$display("a = %0d, b = %0d, sum = %0d", a, b, result); 
a = 8'd100; 
b = 8'd50; 
add_two_numbers(a, b, result); 
$display("a = %0d, b = %0d, sum = %0d", a, b, result); 
$finish; 
end 
endmodule 

// Testbench for task_sum module  
`timescale 1ns/1ps 
module tb_task_sum; 
reg [7:0] a, b;  
wire [7:0] result; 
task_sum DUT(); 
initial begin  
$display("Running testbench for task-based sum..."); #50;   
$finish; 
end 
endmodule 
 
OUTPUT 
a = 15, b = 25, sum = 40 
a = 100, b = 50, sum = 10 
