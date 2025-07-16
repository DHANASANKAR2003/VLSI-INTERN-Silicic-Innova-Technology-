module queue_basics;
  int q[$] = {1,2,3,4,5};
  
  initial begin
    foreach(q[i])
      $display("q[%0d] = %0d",i,q[i]);
  end
endmodule
