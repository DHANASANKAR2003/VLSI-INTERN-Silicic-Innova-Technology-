class calculator;
  function int add(int a, int b);
    return a + b;
  endfunction
  
  function int multi(int a, int b);
    return a * b;
  endfunction
  
endclass

module test1;
  
  initial begin
    calculator c = new();
    $display("addition = %0d",c.add(2,4));
    $display("Multiplication = %0d",c.multi(2,4));
  end
endmodule
    
