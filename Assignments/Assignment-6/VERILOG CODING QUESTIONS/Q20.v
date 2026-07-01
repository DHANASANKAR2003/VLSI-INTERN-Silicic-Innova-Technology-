20. Implement a 4-bit ripple carry adder.
//Design Code
module ripple_carry_adder_4bit (
  input  [3:0] A, B,
  input        Cin,
  output [3:0] Sum,
  output       Cout
);

  wire c1, c2, c3;

  full_adder FA0 (.a(A[0]), 
                  .b(B[0]), 
                  .cin(Cin),  
                  .sum(Sum[0]), 
                  .cout(c1));
  full_adder FA1 (.a(A[1]), 
                  .b(B[1]), 
                  .cin(c1),   
                  .sum(Sum[1]), 
                  .cout(c2));
  full_adder FA2 (.a(A[2]), 
                  .b(B[2]), 
                  .cin(c2),   
                  .sum(Sum[2]), 
                  .cout(c3));
  full_adder FA3 (.a(A[3]), 
                  .b(B[3]), 
                  .cin(c3),   
                  .sum(Sum[3]), 
                  .cout(Cout));

endmodule

module full_adder (
  input  a, b, cin,
  output sum, cout
);
  assign sum  = a ^ b ^ cin;
  assign cout = (a & b) | (b & cin) | (a & cin);
endmodule
//Testbench code
`timescale 1ns/1ps
module ripple_carry_adder_4bit_tb;

  reg [3:0] A, B;
  reg Cin;
  wire [3:0] Sum;
  wire Cout;
  
  ripple_carry_adder_4bit dut (
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
    A = 4'b0011; B = 4'b0101; Cin = 1; #10;
    A = 4'b1000; B = 4'b1000; Cin = 0; #10;
    A = 4'b1111; B = 4'b0001; Cin = 1; #10;
    A = 4'b1111; B = 4'b1111; Cin = 1; #10;

    $finish;
  end
endmodule

OUTPUT
Time	 A	    B	 Cin	Sum	Cout
0	    0000	0000	0	  0000	0
10000	0001	0010	0   0011	0
20000	0011	0101	1	  1001	0
30000	1000	1000	0	  0000	1
40000	1111	0001	1	  0001	1
50000	1111	1111	1	  1111	1
