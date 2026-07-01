class packet;
  integer i = 1;
  virtual function integer init();
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
    packet p1 = c1;
    
    j = p1.init();
    $display("value of J : %0d",j);
  end
endmodule
