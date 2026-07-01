class packet;
  bit[3:0] addr;
  const int data = 8;
  
  function void display();
    $display("addr = %0h data = %0h",addr,data);
  endfunction
endclass

module class_example;
  packet p1;
  initial begin
    p1 = new();
    p1.addr = 4'h4;
    p1.display();
  end
endmodule
