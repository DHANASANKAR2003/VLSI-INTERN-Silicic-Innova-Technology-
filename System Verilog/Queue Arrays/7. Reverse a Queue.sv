 module queue_sort;
   int q[$] = {50,70,90,60,80,10, 20, 30, 40};
  

  initial begin
    q.reverse();
    $display("Reversed Queue : %p", q);
  end
endmodule
