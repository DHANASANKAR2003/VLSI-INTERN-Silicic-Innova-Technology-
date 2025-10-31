module unc_call_from_display;
  initial begin
    $display("sum of var1 + var2 is %0d",sum(5,7));
  end
  
  function int sum(input int var1, var2);
    return var1 + var2;
  endfunction
endmodule

output

sum of var1 + var2 is 12
