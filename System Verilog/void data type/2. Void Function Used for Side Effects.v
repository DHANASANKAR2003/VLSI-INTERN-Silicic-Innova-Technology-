module void_function_example;
  function void print_sum(int a, int b);
    $display("sum = %0d",a + b);
  endfunction
  
  initial begin
    print_sum(4,6);
  end
endmodule 

This SystemVerilog module defines a void function print_sum(int a, int b), where a and b are of int (integer) data type and the return type is void, meaning it returns no value.
The function is called inside the initial block with values 4 and 6, and it displays their sum using $display.
