7. Write a Verilog function to shift the input data 1 bit to the right. 

module shift_right_function; 
 
  function [7:0] right_shift; 
    input [7:0] data_in; 
    begin 
      right_shift = data_in >> 1; 
    end 
  endfunction 
 
  // Test the function 
  reg [7:0] input_data; 
  reg [7:0] shifted_data; 
 
  initial begin 
    input_data = 8'b10110110; 
    shifted_data = right_shift(input_data); 
    $display("Original Data = %b", input_data); 
    $display("Shifted Data  = %b", shifted_data); 
  end 
 
endmodule 

Output : 

Original Data = 10110110   
Shifted Data  = 01011011 
