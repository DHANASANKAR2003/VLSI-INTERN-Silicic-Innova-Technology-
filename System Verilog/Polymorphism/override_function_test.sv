class packet;
  integer i = 1;
  function integer init();
    init = i;
  endfunction
endclass

class child_packet extends packet;
  integer i = 2;
  function integer init();
    init = -i;
  endfunction
endclass

module test;
  int i,j;
  initial begin
    child_packet c1 = new();
    packet p1 = new();
    
    i = p1.init();
    $display("packet value : %0d",i);
    
    j = c1.init();
    $display("child_packet : %0d",j);
  end
endmodule
