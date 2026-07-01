
module func_default_value;
  int result;
  initial begin
    $display("\n ----output for function passing by values through variables-----");
    $display("\tcalling the function");
    
    result=sum();
    $display("\treturned from function and");
    $display("\tstored the value of sum in result");
    $display("\n\t@ %0t ns, value of sum is %0d\n",$time,result);
  end

  function int sum(input int var1=9,var2=3);
    $display("\n\tentered into function");
 
    return var1+var2;
  endfunction 

endmodule : func_default_value

output

----output for function passing by values through variables-----
	calling the function

	entered into function
	returned from function and
	stored the value of sum in result

	@ 0 ns, value of sum is 12
