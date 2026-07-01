class packet;
  int data;
  
  function void set(int d);
    data = d;
  endfunction
  
  function void print();
    $display("DATA = %0d",data);
  endfunction
  
endclass

module test1;
  function void process(packet p);
    p.set(99);
    p.print();
  endfunction
  
  initial begin
    packet pkt = new();
    process(pkt);
  end
endmodule
    
