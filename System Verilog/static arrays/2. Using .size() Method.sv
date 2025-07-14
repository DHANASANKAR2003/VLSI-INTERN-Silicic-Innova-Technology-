module static_array_size;
  int arr[5] = '{10,20,30,40,50};
  
  initial begin
    $display("array size = %0d",$size(arr));
  end
endmodule

  
  
