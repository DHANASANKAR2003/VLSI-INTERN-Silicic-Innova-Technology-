module static_array_reverse;
  int arr[5] = '{1, 2, 3, 4, 5};

  initial begin
    arr.reverse();
    foreach (arr[i])
      $display("arr[%0d] = %0d", i, arr[i]);
  end
endmodule
