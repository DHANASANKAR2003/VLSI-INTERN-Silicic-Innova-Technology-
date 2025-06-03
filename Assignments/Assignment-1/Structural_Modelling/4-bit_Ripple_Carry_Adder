13. Design a 4-bit Ripple Carry Adder using structural modeling
//Design Code
module full_adder(
    input A, B, Cin,
    output Sum, Cout
);
    assign Sum = A ^ B ^ Cin;
    assign Cout = (A & B) | (B & Cin) | (Cin & A);
endmodule

module ripple_carry_adder_4bit(
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] Sum,
    output Cout
);
    wire c1, c2, c3;

    full_adder FA0 (.A(A[0]), .B(B[0]), .Cin(Cin),  .Sum(Sum[0]), .Cout(c1));
    full_adder FA1 (.A(A[1]), .B(B[1]), .Cin(c1),   .Sum(Sum[1]), .Cout(c2));
    full_adder FA2 (.A(A[2]), .B(B[2]), .Cin(c2),   .Sum(Sum[2]), .Cout(c3));
    full_adder FA3 (.A(A[3]), .B(B[3]), .Cin(c3),   .Sum(Sum[3]), .Cout(Cout));
endmodule

// Testbench for 4-bit Ripple Carry Adder
module ripple_carry_adder_4bit_tb;

    reg [3:0] A, B;
    reg Cin;
    wire [3:0] Sum;
    wire Cout;

    ripple_carry_adder_4bit uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );
    initial begin
        // Test case 1
        A = 4'b0001; B = 4'b0010; Cin = 0;
        #10;
        $display("A=%b, B=%b, Cin=%b => Sum=%b, Cout=%b", A, B, Cin, Sum, Cout);

        // Test case 2
        A = 4'b1111; B = 4'b0001; Cin = 0;
        #10;
        $display("A=%b, B=%b, Cin=%b => Sum=%b, Cout=%b", A, B, Cin, Sum, Cout);

        // Test case 3
        A = 4'b1010; B = 4'b0101; Cin = 1;
        #10;
        $display("A=%b, B=%b, Cin=%b => Sum=%b, Cout=%b", A, B, Cin, Sum, Cout);

        // Test case 4
        A = 4'b1111; B = 4'b1111; Cin = 1;
        #10;
        $display("A=%b, B=%b, Cin=%b => Sum=%b, Cout=%b", A, B, Cin, Sum, Cout);

        $finish;
    end
endmodule

//Output
A=0001, B=0010, Cin=0 => Sum=0011, Cout=0
A=1111, B=0001, Cin=0 => Sum=0000, Cout=1
A=1010, B=0101, Cin=1 => Sum=0000, Cout=1
A=1111, B=1111, Cin=1 => Sum=1111, Cout=1
testbench.sv:38: $finish called at 40 (1s)
