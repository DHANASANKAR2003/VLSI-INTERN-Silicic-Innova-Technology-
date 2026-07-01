module static_array_product;
  int arr[4] = '{2, 3, 4, 5};

  initial begin
    int p = arr.product();
    $display("Product of all elements = %0d", p);
  end
endmodule
