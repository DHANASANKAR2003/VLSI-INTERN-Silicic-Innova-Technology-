 module dyn_array_reverse;
  int da[] = '{1, 2, 3, 4, 5};

  initial begin
    da.reverse();
    foreach (da[i])
      $display("da[%0d] = %0d", i, da[i]);
  end
endmodule
