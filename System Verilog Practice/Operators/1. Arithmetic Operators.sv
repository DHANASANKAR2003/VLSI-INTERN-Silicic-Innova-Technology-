//operators
//1.Arithmetic operators

module arithmetic;
  int a = 5;
  int b = 5;
  int y;
  
  initial begin
    $display("Value of a is %0d",a);
    $display("Value of b is %0d",b);
    
    //Addition
    y = a + b;
    $display("Addition a + b is %0d",y);
    
    //Sub
    y = a - b;
    $display("Subtraction a - b is %0d",y);
    
    //Multiplication
    y = a * b;
    $display("Multiplication a * b is %0d",y);
    
    //Division
    y = a / b;
    $display("Division a / b is %0d",y);
    
    //Modulus
    y = a % b;
    $display("modulus a modulus b is %0d",y);
    
    //Power
    y = a ** b;
    $display("Power a ** b is %0d",y);
  end
endmodule

    
    
OUTPUT

Value of a is 5
Value of b is 5
Addition a + b is 10
Subtraction a - b is 0
Multiplication a * b is 25
Division a / b is 1
modulus a modulus b is 0
Power a ** b is 3125
