
11. Write Verilog code to shift a number right using a function. 

module right_shift_function; 
 
  reg [7:0] data; 
  reg [2:0] shift_amount; 
  reg [7:0] result; 
 
  // Function to shift right 
  function [7:0] shift_right; 
    input [7:0] value; 
    input [2:0] amount; 
    begin 
      shift_right = value >> amount; 
    end 
  endfunction 
 
  initial begin 
    data = 8'b11010110;      // Example binary number 
    shift_amount = 3'd2;     // Shift right by 2 bits 
 
    result = shift_right(data, shift_amount); 
 
    $display("Original Data = %b", data); 
    $display("Shift Amount = %d", shift_amount); 
    $display("Shifted Data = %b", result); 
  end 
 
endmodule 
 

 

Output 

Original Data = 11010110 
Shift Amount = 2 
Shifted Data = 00110101
