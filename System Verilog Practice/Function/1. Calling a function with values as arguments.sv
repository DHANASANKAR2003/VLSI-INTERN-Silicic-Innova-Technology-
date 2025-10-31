module function_pass_by_value;
  int result;
  initial begin
    result = sum(5,5);
    $display("sum of var1 + var2 is %0d",result);
  end
  
  function int sum(input int var1, var2);
    return var1 + var2;
  endfunction
endmodule


output

sum of var1 + var2 is 10
