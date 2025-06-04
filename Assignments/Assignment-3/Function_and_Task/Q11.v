Write Verilog code to perform arithmetic operations using tasks. 

 

module arithmetic_task; 
 
  reg [7:0] a, b; 
  reg [15:0] result; 
 
  // Task for Addition 
  task add; 
    input [7:0] x, y; 
    output [15:0] sum; 
    begin 
      sum = x + y; 
    end 
  endtask 
 
  // Task for Subtraction 
  task sub; 
    input [7:0] x, y; 
    output [15:0] diff; 
    begin 
      diff = x - y; 
    end 
  endtask 
 
  // Task for Multiplication 
  task mul; 
    input [7:0] x, y; 
    output [15:0] prod; 
    begin 
      prod = x * y; 
    end 
  endtask 
 
  // Task for Division 
  task div; 
    input [7:0] x, y; 
    output [15:0] quotient; 
    begin 
      if (y != 0) 
        quotient = x / y; 
      else 
        quotient = 16'hXXXX;  

    end 
  endtask 
 
  initial begin 
    a = 8'd20; 
    b = 8'd5; 
 
    add(a, b, result); 
    $display("Addition: %d + %d = %d", a, b, result); 
 
    sub(a, b, result); 
    $display("Subtraction: %d - %d = %d", a, b, result); 
 
    mul(a, b, result); 
    $display("Multiplication: %d * %d = %d", a, b, result); 
 
    div(a, b, result); 
    $display("Division: %d / %d = %d", a, b, result); 
  end 
 
endmodule 
 

Output  

makefile 

CopyEdit 

Addition: 20 + 5 = 25 
Subtraction: 20 - 5 = 15 
Multiplication: 20 * 5 = 100 
Division: 20 / 5 = 4 
