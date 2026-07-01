module func_pass_by_positional;
  int result;
  initial begin
    result = sum(.var1(5),.var2(6));
    $display("sum of var1 + var2 is %0d",result);
  end
  
  function int sum(input int var1, var2);
    return var1 + var2;
  endfunction
endmodule

output

sum of var1 + var2 is 11
