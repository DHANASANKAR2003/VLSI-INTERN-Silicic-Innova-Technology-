13. Write Verilog code where a function can call another function. 

module function_calling_function; 
  function automatic int double_value(input int x); 
    double_value = 2 * x; 
  endfunction 
  function automatic int square_double(input int x); 
    int temp; 
    temp = double_value(x);       
    square_double = temp * temp;   
  endfunction 
  initial begin 
    int val = 3; 
    int result; 
    result = square_double(val); 
    $display("Input = %0d", val); 
    $display("Double of input = %0d", double_value(val)); 
    $display("Square of double = %0d", result); // (2*3)^2 = 36 
  end 
 
endmodule 

OUTPUT 

Input = 3 
Double of input = 6 
Square of double = 36 

 
