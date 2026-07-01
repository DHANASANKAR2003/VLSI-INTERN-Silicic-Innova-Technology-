module staic_array_basic;
  int arr[5] = '{1,2,3,4,5};
  
  initial begin
    foreach(arr[i])
      $display("arr[%0d] = %0d",i,arr[i]);
  end
endmodule
