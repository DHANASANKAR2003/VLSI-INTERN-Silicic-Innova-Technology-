 module queue_size;
  int q[$] = '{10, 20, 30, 40};
  int indx[$]; 

  initial begin
    indx = q.find_index(x) with (x == 20);
    $display("Index queue for 20: %p", indx);
  end
endmodule
