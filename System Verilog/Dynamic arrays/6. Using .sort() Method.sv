 module dyn_array_sort;
   int da[] = '{9,7,8,5,6,2,3,1,4};

  initial begin
    da.sort();
    foreach (da[i])
      $display("sorted array da[%0d] = %0d", i, da[i]);
  end
endmodule
