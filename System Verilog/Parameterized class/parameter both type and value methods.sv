class packet #(parameter WIDTH = 4,type T = int);
  bit[WIDTH-1:0] addr;
  T data;
  
  function void display();
    $display("addr = %0d data = %0d",addr,data);
  endfunction
endclass

module class_example;
  packet p4_int;
  packet #(8,bit[7:0]) p8_bit;
  
  initial begin
    p4_int = new();
    p8_bit = new();
    
    p4_int.addr = 15;
    p4_int.data = 100;
    p4_int.display();
    
    p8_bit.addr = 16;
    p8_bit.data = 255;
    p8_bit.display();
    
  end
endmodule
