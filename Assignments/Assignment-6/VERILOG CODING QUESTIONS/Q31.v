31. Design a 4-bit signed multiplier.
//Design Code
module signed_multiplier_4bit (
    input  signed [3:0] A,
    input  signed [3:0] B,
    output signed [7:0] Product
);

  assign Product = A * B;

endmodule
//Testbench code
module tb_signed_multiplier_4bit;

  reg signed [3:0] A, B;
  wire signed [7:0] Product;

  signed_multiplier_4bit uut (
    .A(A),
    .B(B),
    .Product(Product)
  );

  initial begin
    $display("A\tB\tProduct");
    A = 4'sd3;  B = 4'sd2;  #10; 
    $display("%d\t%d\t%d", A, B, Product);
    A = -4'sd4; B = 4'sd3;  #10; 
    $display("%d\t%d\t%d", A, B, Product);
    A = -4'sd3; B = -4'sd2; #10; 
    $display("%d\t%d\t%d", A, B, Product);
    A = 4'sd7;  B = 4'sd7;  #10; 
    $display("%d\t%d\t%d", A, B, Product);
    A = -4'sd8; B = 4'sd1;  #10; 
    $display("%d\t%d\t%d", A, B, Product);
    A = 4'sd5;  B = -4'sd3; #10; 
    $display("%d\t%d\t%d", A, B, Product);
    $finish;
  end

endmodule

OUTPUT
A	B	 Product
 3	 2	   6
-4	 3	 -12
-3	-2	   6
 7	 7	  49
-8	 1	  -8
 5	-3	 -15
