module queue_foreach;
  int q[$] = {11, 22, 33};

  initial begin
    foreach (q[i])
      $display("q[%0d] = %0d", i, q[i]);
  end
endmodule
