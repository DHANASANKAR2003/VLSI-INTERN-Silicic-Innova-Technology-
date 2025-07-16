module queue_unique;
  int q[$] = {1, 2, 2, 3, 1, 4};

  initial begin
    q.unique();
    $display("Unique queue: %p", q);
  end
endmodule
