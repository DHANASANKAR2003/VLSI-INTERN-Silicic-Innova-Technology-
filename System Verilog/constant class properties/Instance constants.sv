class packet;
  bit[3:0] addr;
  const int data;
  
  function new();
    addr = 4'h5;
    data = 12;
  endfunction
  
  function void display();
    $display("addr = %0h data = %0h",addr,data);
  endfunction
endclass

module class_example;
  packet p1;
  initial begin
    p1 = new();
    p1.display();
  end
endmodule
