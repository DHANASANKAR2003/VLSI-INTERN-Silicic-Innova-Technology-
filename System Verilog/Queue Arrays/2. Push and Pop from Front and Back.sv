module queue_push_pop;
  int q[$];
  
  initial begin
    q.push_front(10);
    q.push_back(5);
    $display("After push = %p",q);
    
    q.pop_front();
    q.pop_back();
    $display("After pop = %p",q);
  end
endmodule
