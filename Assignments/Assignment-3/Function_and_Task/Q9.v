Write Verilog code where a task can call both a task and a function. 

 

module task_calls_task_and_function; 
 
  reg [7:0] a, b, result; 
  reg [15:0] final_result; 
 
  // Function: multiply two 8-bit numbers 
  function [15:0] multiply; 
    input [7:0] x, y; 
    begin 
      multiply = x * y; 
    end 
  endfunction 
 
  // Task: adds two 8-bit numbers 
  task add; 
    input [7:0] x, y; 
    output [7:0] sum; 
    begin 
      sum = x + y; 
    end 
  endtask 
 
  // Task: calls both add task and multiply function 
  task process_data; 
    input [7:0] x, y; 
    output [15:0] result_out; 
    reg [7:0] sum_temp; 
    begin 
      $display("Calling add task..."); 
      add(x, y, sum_temp);             // Calling task 
      $display("Sum = %d", sum_temp); 
 
      $display("Calling multiply function..."); 
      result_out = multiply(x, y);     // Calling function 
    end 
  endtask 
 
  initial begin 
    a = 8'd5; 
    b = 8'd6; 
 
    $display("Initial values: a = %d, b = %d", a, b); 
 
    process_data(a, b, final_result); 
 
    $display("Multiplication result = %d", final_result); 
  end 
 
endmodule 
OUTPUT 

Initial values: a = 5, b = 6 
Calling add task... 
Sum = 11 
Calling multiply function... 
Multiplication result = 30 

 
