class packet;
  protected int i;
endclass

class child_packet extends packet;
  function void display(int a);
    i = a;
    $display("value of i = %0d",i);
  endfunction
endclass

module class_example;
  initial begin
    child_packet c1 = new();
    c1.display(10);
  end
endmodule 

