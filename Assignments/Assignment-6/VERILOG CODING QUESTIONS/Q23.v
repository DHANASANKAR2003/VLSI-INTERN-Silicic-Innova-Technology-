23. Implement a full adder using half adders.
//Design Code

module half_adder (
  input A, B,
  output sum, carry
);
  assign sum = A ^ B;
  assign carry = A & B;
endmodule

module full_adder_using_half_adders (
  input A, B, Cin,
  output Sum, Cout
);

  wire sum1, carry1, carry2;

  half_adder HA1 (
    .A(A), 
    .B(B), 
    .sum(sum1), 
    .carry(carry1));
  half_adder HA2 (
    .A(sum1), 
    .B(Cin), 
    .sum(Sum), 
    .carry(carry2));

  assign Cout = carry1 | carry2;

endmodule

//Testbench code
module tb_full_adder;

  reg A, B, Cin;
  wire Sum, Cout;

  full_adder_using_half_adders uut (
    .A(A), 
    .B(B), 
    .Cin(Cin), 
    .Sum(Sum), 
    .Cout(Cout)
  );

  initial begin
    $display("A B Cin | Sum Cout");
    $display("------------------");
    A = 0; B = 0; Cin = 0; #10;
    $display("%b %b  %b  |  %b   %b", A, B, Cin, Sum, Cout);

    A = 0; B = 0; Cin = 1; #10;
    $display("%b %b  %b  |  %b   %b", A, B, Cin, Sum, Cout);

    A = 0; B = 1; Cin = 0; #10;
    $display("%b %b  %b  |  %b   %b", A, B, Cin, Sum, Cout);

    A = 0; B = 1; Cin = 1; #10;
    $display("%b %b  %b  |  %b   %b", A, B, Cin, Sum, Cout);

    A = 1; B = 0; Cin = 0; #10;
    $display("%b %b  %b  |  %b   %b", A, B, Cin, Sum, Cout);

    A = 1; B = 0; Cin = 1; #10;
    $display("%b %b  %b  |  %b   %b", A, B, Cin, Sum, Cout);

    A = 1; B = 1; Cin = 0; #10;
    $display("%b %b  %b  |  %b   %b", A, B, Cin, Sum, Cout);

    A = 1; B = 1; Cin = 1; #10;
    $display("%b %b  %b  |  %b   %b", A, B, Cin, Sum, Cout);

    $finish;
  end

endmodule

OUTPUT
A B Cin | Sum Cout
------------------
0 0  0  |  0   0
0 0  1  |  1   0
0 1  0  |  1   0
0 1  1  |  0   1
1 0  0  |  1   0
1 0  1  |  0   1
1 1  0  |  0   1
1 1  1  |  1   1
