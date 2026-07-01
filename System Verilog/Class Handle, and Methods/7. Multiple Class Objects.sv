class car;
  string brand;
endclass

module test1;
  initial begin
    car c1 = new();
    car c2 = new();
    
    c1.brand = "BMW";
    c2.brand = "Tesla";
    
    $display("car 1 = %s",c1.brand);
    $display("car 2 = %s",c2.brand);
  end
endmodule
    
