module dynamic_arr_basic;
  int da[];
  
  initial begin
    da = new[5];
    da = '{1,2,3,4,5};
    foreach(da[i])
      $display("dynamic array[%0d] = %0d",i,da[i]);
  end
endmodule 
