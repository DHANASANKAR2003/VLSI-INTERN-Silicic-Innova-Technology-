21. Implement a 4-bit carry look-ahead adder.
//Design Code
// 4-bit Carry Look-Ahead Adder
module carry_lookahead_adder_4bit (
  input  [3:0] A,
  input  [3:0] B,
  input        Cin,
  output [3:0] Sum,
  output       Cout
);

  wire [3:0] G, P, C;

  assign G = A & B;    
  assign P = A ^ B;      
  assign C[0] = Cin;
  assign C[1] = G[0] | (P[0] & C[0]);
  assign C[2] = G[1] | (P[1] & C[1]);
  assign C[3] = G[2] | (P[2] & C[2]);
  assign Cout = G[3] | (P[3] & C[3]);
  assign Sum = P ^ C;

endmodule
//Testbench code
`timescale 1ns/1ps

module carry_lookahead_adder_4bit_tb;

  reg  [3:0] A, B;
  reg        Cin;
  wire [3:0] Sum;
  wire       Cout;

  carry_lookahead_adder_4bit uut (
    .A(A),
    .B(B), 
    .Cin(Cin),
    .Sum(Sum), 
    .Cout(Cout)
  );

  initial begin
    $display("Time\tA\tB\tCin\tSum\tCout");
    $monitor("%0t\t%b\t%b\t%b\t%b\t%b", $time, A, B, Cin, Sum, Cout);

    A = 4'b0000; B = 4'b0000; Cin = 0; #10;
    A = 4'b0001; B = 4'b0010; Cin = 0; #10;
    A = 4'b0110; B = 4'b0101; Cin = 1; #10;
    A = 4'b1001; B = 4'b0111; Cin = 0; #10;
    A = 4'b1111; B = 4'b0001; Cin = 1; #10;
    A = 4'b1111; B = 4'b1111; Cin = 1; #10;

    $finish;
  end
endmodule

OUTPUT
Time	  A	    B	 Cin	Sum	 Cout
0	    0000	0000	0	  0000	0
10000	0001	0010	0	  0011	0
20000	0110	0101	1	  1100	0
30000	1001	0111	0	  0000	1
40000	1111	0001	1	  0001	1
50000	1111	1111	1	  1111	1
