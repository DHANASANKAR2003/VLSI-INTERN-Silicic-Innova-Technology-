//operators
//3.Equality operator

module Relational;
  logic[3:0] a,b,c,y;
  
  initial begin
    a = 4'bx0x1;
    b = 4'b1100;
    c = 4'bx0x1;
    
    $display("Value of a is %0b",a);
    $display("Value of b is %0b",b);
    $display("Value of c is %0b",c);
    
    //Greater
    y = a == b;
    $display("logical equal a == b is %0d",y);
    
    //Lesthen
    y = a != b;
    $display("logical inequal a !== b is %0d",y);
    
    //Greater equal
    y = a === b;
    $display("case equal a === b is %0d",y);
    
    //Lesthen equal
    y = a !== b;
    $display("case inequal a !=== b is %0d",y);
    
  end
endmodule

    
    
OUTPUT
Value of a is x0x1
Value of b is 1100
Value of c is x0x1
logical equal a == b is 0
logical inequal a !== b is 1
case equal a === b is 0
case inequal a !=== b is 1

