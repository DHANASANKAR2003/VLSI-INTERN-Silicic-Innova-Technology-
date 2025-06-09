24. Design a 4-bit full adder using 1-bit full adders.
//Design Code

module full_adder_1bit (
  input A, B, Cin,
  output Sum, Cout
);
  assign Sum = A ^ B ^ Cin;
  assign Cout = (A & B) | (B & Cin) | (A & Cin);
endmodule
module full_adder_4bit (
  input [3:0] A, B,
  input Cin,
  output [3:0] Sum,
  output Cout
);

  wire C1, C2, C3;

  full_adder_1bit FA0 (
    .A(A[0]), 
    .B(B[0]), 
    .Cin(Cin), 
    .Sum(Sum[0]), 
    .Cout(C1));
  full_adder_1bit FA1 (
    .A(A[1]), 
    .B(B[1]), 
    .Cin(C1),  
    .Sum(Sum[1]), 
    .Cout(C2));
  full_adder_1bit FA2 (
    .A(A[2]), 
    .B(B[2]), 
    .Cin(C2),  
    .Sum(Sum[2]), 
    .Cout(C3));
  full_adder_1bit FA3 (
    .A(A[3]), 
    .B(B[3]), 
    .Cin(C3),  
    .Sum(Sum[3]), .Cout(Cout));

endmodule
//Testbench code
module tb_full_adder_4bit;

  reg [3:0] A, B;
  reg Cin;
  wire [3:0] Sum;
  wire Cout;

  full_adder_4bit uut (
    .A(A), 
    .B(B), 
    .Cin(Cin), 
    .Sum(Sum), 
    .Cout(Cout)
  );

  initial begin
    $display("Time\tA\tB\tCin\tSum\tCout");
    $display("--------------------------------------------");

    A = 4'b0000; B = 4'b0000; Cin = 0; #10;
    $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, A, B, Cin, Sum, Cout);

    A = 4'b0011; B = 4'b0101; Cin = 0; #10;
    $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, A, B, Cin, Sum, Cout);

    A = 4'b1010; B = 4'b0110; Cin = 1; #10;
    $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, A, B, Cin, Sum, Cout);

    A = 4'b1111; B = 4'b1111; Cin = 0; #10;
    $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, A, B, Cin, Sum, Cout);

    A = 4'b1111; B = 4'b1111; Cin = 1; #10;
    $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, A, B, Cin, Sum, Cout);

    $finish;
  end

endmodule

OUTPUT
Time	A	   B	 Cin  Sum	 Cout
-----------------------------
10	0000	0000	0	  0000	0
20	0011	0101	0	  1000	0
30	1010	0110	1	  0001	1
40	1111	1111	0	  1110	1
50	1111	1111	1	  1111	1
