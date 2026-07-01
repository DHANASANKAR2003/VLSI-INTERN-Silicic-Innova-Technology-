module void_discard_example;
  function int add(int a, int b);
    return (a + b);
  endfunction
  
  initial begin 
    void'(add(3,7));
    $display("return = %0d",add(3,7));
  end
endmodule 
