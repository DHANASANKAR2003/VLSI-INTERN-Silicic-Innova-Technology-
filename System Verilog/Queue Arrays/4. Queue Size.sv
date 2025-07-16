module queue_size;
  int q[$] = {10,20,30};
  
  initial begin
    $display("Queue size = %0d",q.size());
  end
endmodule
