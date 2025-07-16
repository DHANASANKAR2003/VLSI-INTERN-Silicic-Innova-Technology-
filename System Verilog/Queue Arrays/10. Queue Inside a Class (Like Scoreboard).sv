class PacketQueue;
  int queue[$];

  function void add(int pkt);
    queue.push_back(pkt);
  endfunction

  function void display();
    foreach (queue[i])
      $display("Packet %0d: %0d", i, queue[i]);
  endfunction
endclass

module queue_class_test;
  initial begin
    PacketQueue pq = new();
    pq.add(100);
    pq.add(200);
    pq.display();
  end
endmodule
