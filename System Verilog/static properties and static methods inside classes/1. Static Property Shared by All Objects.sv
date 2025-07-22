class counter;
  static int count = 0;
  
  function void increase();
    count++;
  endfunction
  
  function void display();
    $display("current count : %0d",count);
  endfunction
  
endclass

module test;
  initial begin
    counter c1 = new();
    counter c2 = new();
  
    c1.increase();
    c2.increase();
    c2.display();
  end
endmodule
