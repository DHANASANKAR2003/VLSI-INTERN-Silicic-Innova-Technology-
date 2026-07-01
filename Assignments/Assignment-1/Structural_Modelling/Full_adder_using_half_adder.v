
//Design Code
// Structural model of a Full Adder using Half Adders
module half_adder (
    input A, B,
    output Sum, Carry
);
    xor (Sum, A, B);
    and (Carry, A, B);
endmodule
module full_adder_using_half_adder (
    input A, B, Cin,
    output Sum, Cout
);
    wire Sum1, Carry1, Carry2;
    half_adder HA1 (
        .A(A),
        .B(B),
        .Sum(Sum1),
        .Carry(Carry1)
    );
    half_adder HA2 (
        .A(Sum1),
        .B(Cin),
        .Sum(Sum),
        .Carry(Carry2)
    );
    or (Cout, Carry1, Carry2);
endmodule

//Test Bench code 
 `timescale 1ns/1ps

module full_adder_tb;
    reg A, B, Cin;
    wire Sum, Cout;
    full_adder_using_half_adder uut (
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
        $display("%b %b  %b   |  %b    %b", A, B, Cin, Sum, Cout);
        A = 0; B = 0; Cin = 1; #10;
        $display("%b %b  %b   |  %b    %b", A, B, Cin, Sum, Cout);
        A = 0; B = 1; Cin = 0; #10;
        $display("%b %b  %b   |  %b    %b", A, B, Cin, Sum, Cout);
        A = 0; B = 1; Cin = 1; #10;
        $display("%b %b  %b   |  %b    %b", A, B, Cin, Sum, Cout);
        A = 1; B = 0; Cin = 0; #10;
        $display("%b %b  %b   |  %b    %b", A, B, Cin, Sum, Cout);
        A = 1; B = 0; Cin = 1; #10;
        $display("%b %b  %b   |  %b    %b", A, B, Cin, Sum, Cout);
        A = 1; B = 1; Cin = 0; #10;
        $display("%b %b  %b   |  %b    %b", A, B, Cin, Sum, Cout);
        A = 1; B = 1; Cin = 1; #10;
        $display("%b %b  %b   |  %b    %b", A, B, Cin, Sum, Cout);
        $finish;
    end
endmodule

//Output
A B Cin | Sum Cout
------------------
0 0  0   |  0    0
0 0  1   |  1    0
0 1  0   |  1    0
0 1  1   |  0    1
1 0  0   |  1    0
1 0  1   |  0    1
1 1  0   |  0    1
1 1  1   |  1    1
testbench.sv:32: $finish called at 80000 (1ps)
