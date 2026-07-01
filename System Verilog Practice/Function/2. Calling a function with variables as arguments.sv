module function_pass_by_value;
  int result,a = 5,b = 6;
  initial begin
    result = sum(a,b);
    $display("sum of var1 + var2 is %0d",result);
  end
  
  function int sum(input int var1, var2);
    return var1 + var2;
  endfunction
endmodule

output

sum of var1 + var2 is 11
