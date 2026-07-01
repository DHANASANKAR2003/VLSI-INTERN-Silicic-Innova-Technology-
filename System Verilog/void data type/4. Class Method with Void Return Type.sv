class mathop;
  function void multi(int a, int b);
    $display("product : %0d",a * b);
  endfunction
endclass

module class_void_method;
  initial begin
    mathop m = new();
    m.multi(3,3);
  end 
endmodule 
