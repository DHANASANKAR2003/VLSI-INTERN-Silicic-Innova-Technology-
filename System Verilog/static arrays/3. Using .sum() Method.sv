module static_array_sum;
  int arr[5] = '{10,20,30,40,50};
  
  initial begin
    int total = arr.sum();
    $display("array sum = %0d",total);
  end
endmodule

  
  
