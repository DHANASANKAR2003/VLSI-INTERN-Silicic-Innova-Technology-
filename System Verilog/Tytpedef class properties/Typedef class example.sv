typedef class data_packet;
  class packet;
    bit[3:0] addr;
    data_packet d1 = new();
    
    function void display();
      $display("addr = %0h data = %0h",addr,d1.data);
    endfunction
  endclass
  
  class data_packet;
    int data = 12;
  endclass
  
  module class_example;
    packet p1;
    
    initial begin
      p1 = new();
      p1.addr = 4'h4;
      p1.display();
    end
  endmodule
