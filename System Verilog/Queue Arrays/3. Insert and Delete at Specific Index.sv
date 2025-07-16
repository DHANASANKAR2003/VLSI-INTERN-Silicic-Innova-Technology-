module queue_insert_delete;
  int q[$] = {10,20,30};
  
  initial begin
    q.insert(1,15);
    $display("After push = %p",q);
    
    q.delete(2);
    $display("After pop = %p",q);
  end
endmodule
