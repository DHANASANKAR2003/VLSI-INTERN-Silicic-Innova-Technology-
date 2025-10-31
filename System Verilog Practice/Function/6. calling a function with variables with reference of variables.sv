module func_pass_by_ref;
  int result,addend,augend;
  initial begin
    $display("\t ----output for function passing by reference -----");
    
    addend=5;
    augend=6;
    $display("\tBefore calling function -> addend = %0d , augend = %0d",addend,augend);
    $display("\tcalling the functions");
    
    result=sum_without_ref(addend,augend);
    
    $display("\tafter calling function without ref -> addend = %0d, augend =%0d",addend,augend);

    
    result=sum_with_ref(addend,augend);
    $display("\tafter calling function with ref -> addend = %0d, augend =%0d",addend,augend);
  end
  
  function automatic int sum_with_ref(ref int var1,var2);
    int temp;
    $display("\n\tentered into with ref function");
    temp=var1;
    var1=var2;
    var2=temp;
    $display("\tswapped variables by using ref ");
    $display("\tafter calling inside the function with ref -> addend = %0d, augend =%0d",var1,var2);
    return var1+var2;
  endfunction : sum_with_ref

  
  function int sum_without_ref(input int var1,var2);
    int temp;
    $display("\n\tentered into without ref function");
    temp=var1;
    var1=var2;
    var2=temp;
    $display("\tswapped variables by without using ref ");
    $display("\tafter calling inside the function without ref -> addend = %0d, augend =%0d",var1,var2);
    return var1+var2;
  endfunction : sum_without_ref

endmodule : func_pass_by_ref

output

 ----output for function passing by reference -----
	Before calling function -> addend = 5 , augend = 6
	calling the functions

	entered into without ref function
	swapped variables by without using ref 
	after calling inside the function without ref -> addend = 6, augend =5
	after calling function without ref -> addend = 5, augend =6

	entered into with ref function
	swapped variables by using ref 
	after calling inside the function with ref -> addend = 6, augend =5
	after calling function with ref -> addend = 6, augend =5
