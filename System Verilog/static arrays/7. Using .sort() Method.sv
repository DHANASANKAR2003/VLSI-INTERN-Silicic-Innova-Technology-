module static_array_sort;
  int arr[5] = '{5,3,8,9,2};
  
  initial begin
    arr.sort();
    $display("array sorted:");
    foreach(arr[i])
      $display("sorted srray[%0d] = %0d",i,arr[i]);
  end
endmodule
