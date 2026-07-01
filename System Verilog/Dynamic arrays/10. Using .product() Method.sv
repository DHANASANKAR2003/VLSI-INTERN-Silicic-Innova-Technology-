module dyn_array_product;
  int da[] = '{2, 3, 4};

  initial begin
    $display("Product of elements: %0d", da.product());
  end
endmodule
