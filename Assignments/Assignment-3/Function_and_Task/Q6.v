Write Verilog code that uses different tasks to perform arithmetic operations. 

module arithmetic_tasks; 
  reg [7:0] a, b; 
  reg [15:0] result; 
  // Task for addition 
  task add; 
    input [7:0] x, y; 
    output [15:0] sum; 
    begin 
      sum = x + y; 
    end 
  endtask 
  // Task for subtraction 
  task sub; 
    input [7:0] x, y; 
    output [15:0] diff; 
    begin 
      diff = x - y; 
    end 
  endtask 
 
  // Task for multiplication 
  task mul; 
    input [7:0] x, y; 
    output [15:0] prod; 
    begin 
      prod = x * y; 
    end 
  endtask 
 
  // Task for division 
  task div; 
    input [7:0] x, y; 
    output [15:0] quot; 
    begin 
      if (y != 0) 
        quot = x / y; 
      else 
        quot = 16'd0; // to avoid divide-by-zero 
    end 
  endtask 
 
  initial begin 
    a = 20; 
    b = 4; 
 
    add(a, b, result); 
    $display("Addition of %d and %d = %d", a, b, result); 
 
    sub(a, b, result); 
    $display("Subtraction of %d and %d = %d", a, b, result); 
 
    mul(a, b, result); 
    $display("Multiplication of %d and %d = %d", a, b, result); 
 
    div(a, b, result); 
    $display("Division of %d by %d = %d", a, b, result); 
 
     
    b = 0; 
    div(a, b, result); 
    $display("Division of %d by %d = %d (safe divide)", a, b, result); 
 
    $finish; 
  end 
 
endmodule 

OUTPUT 

Addition of 20 and 4 = 24 
Subtraction of 20 and 4 = 16 
Multiplication of 20 and 4 = 80 
Division of 20 by 4 = 5 
Division of 20 by 0 = 0 (safe divide) 
design.sv:66: $finish called at 0 (1s) 
