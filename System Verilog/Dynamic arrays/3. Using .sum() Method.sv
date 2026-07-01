module dynamic_arr_basic;
  int da[5] = '{1,2,3,4,5};
  
  initial begin
    $display("sum of dynamic array = %0d",da.sum());
  end
endmodule 
