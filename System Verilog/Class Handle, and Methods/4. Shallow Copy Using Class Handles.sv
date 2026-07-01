class box;
  int weight;
endclass

module test1;
  initial begin
    box b1;
    box b2;
    
    b1 = new();
    b1.weight = 77;
    
    b2 = b1;
    b2.weight = 22;
    
    $display("b1 weight = %0d",b1.weight);
  end
endmodule
    
