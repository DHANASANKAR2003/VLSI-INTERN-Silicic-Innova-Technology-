//operators
//2.Relational operator

module Relational;
  logic[2:0] a = 5;
  logic[2:0] b = 10;
  int y;
  
  initial begin
    $display("Value of a is %0d",a);
    $display("Value of b is %0d",b);
    
    //Greater
    y = a > b;
    $display("Greater a > b is %0d",y);
    
    //Lesthen
    y = a < b;
    $display("Lesthen a < b is %0d",y);
    
    //Greater equal
    y = a >= b;
    $display("Greater equal a >= b is %0d",y);
    
    //Lesthen equal
    y = a <= b;
    $display("Lesthen equal a <= b is %0d",y);
    
  end
endmodule


OUTPUT
Value of a is 5
Value of b is 2
Greater a > b is 1
Lesthen a < b is 0
Greater equal a >= b is 1
Lesthen equal a <= b is 0
    

