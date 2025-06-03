2. Design a 4-bit Arithmetic Logic Unit (ALU) using structural modeling.
//Design Code
// Full Structural 4-bit ALU Verilog Code
// 1. Full Adder Module
module full_adder (
    input a, b, cin,
    output sum, cout
);
    wire axorb, aandb, axorb_and_cin;
    xor (axorb, a, b);
    xor (sum, axorb, cin);
    and (aandb, a, b);
    and (axorb_and_cin, axorb, cin);
    or  (cout, aandb, axorb_and_cin);
endmodule
// 2. 4-bit Adder/Subtractor Module
module add_sub_4bit (
    input [3:0] A, B,
    input sel, // 0 for add, 1 for sub
    output [3:0] S,
    output Cout
);
    wire [3:0] Bx;
    wire [2:0] carry;
    xor (Bx[0], B[0], sel);
    xor (Bx[1], B[1], sel);
    xor (Bx[2], B[2], sel);
    xor (Bx[3], B[3], sel);
    full_adder fa0 (A[0], Bx[0], sel,     S[0], carry[0]);
    full_adder fa1 (A[1], Bx[1], carry[0], S[1], carry[1]);
    full_adder fa2 (A[2], Bx[2], carry[1], S[2], carry[2]);
    full_adder fa3 (A[3], Bx[3], carry[2], S[3], Cout);
endmodule
// 3. Main ALU Module
module alu_4bit (
    input [3:0] A, B,
    input [2:0] sel,
    output [3:0] Result,
    output CarryOut,
    output Zero
);
    wire [3:0] sum, and_out, or_out;
    wire cout;
    // AND and OR operations
    and (and_out[0], A[0], B[0]);
    and (and_out[1], A[1], B[1]);
    and (and_out[2], A[2], B[2]);
    and (and_out[3], A[3], B[3]);
    or  (or_out[0], A[0], B[0]);
    or  (or_out[1], A[1], B[1]);
    or  (or_out[2], A[2], B[2]);
    or  (or_out[3], A[3], B[3]);
    // Adder/Subtractor
    add_sub_4bit u_adder (
        .A(A),
        .B(B),
        .sel(sel[0]),  // 0: Add, 1: Sub
        .S(sum),
        .Cout(cout)
    );
    assign Result = (sel == 3'b000) ? sum :
                    (sel == 3'b001) ? sum :
                    (sel == 3'b010) ? and_out :
                    (sel == 3'b011) ? or_out :
                    4'b0000;
    assign CarryOut = (sel == 3'b000 || sel == 3'b001) ? cout : 1'b0;
    assign Zero = ~|Result;
endmodule

// Test Bench Code
`timescale 1ns/1ps
module alu_4bit_tb;
    // Inputs
    reg [3:0] A, B;
    reg [2:0] sel;
    // Outputs
    wire [3:0] Result;
    wire CarryOut;
    wire Zero;
    // Instantiate the ALU
    alu_4bit uut (
        .A(A),
        .B(B),
        .sel(sel),
        .Result(Result),
        .CarryOut(CarryOut),
        .Zero(Zero)
    );
    initial begin
        $display("Time\tA\tB\tsel\tResult\tCarryOut\tZero");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t\t%b", $time, A, B, sel, Result, CarryOut, Zero);

        // Test ADD: 4 + 3 = 7
        A = 4'b0100; B = 4'b0011; sel = 3'b000; #10;
        // Test SUB: 5 - 2 = 3
        A = 4'b0101; B = 4'b0010; sel = 3'b001; #10;
        // Test AND: 1100 & 1010 = 1000
        A = 4'b1100; B = 4'b1010; sel = 3'b010; #10;
        // Test OR: 1100 | 1010 = 1110
        A = 4'b1100; B = 4'b1010; sel = 3'b011; #10;
        // Test Zero Result: 3 - 3 = 0
        A = 4'b0011; B = 4'b0011; sel = 3'b001; #10;
        // Test Overflow Case: 15 + 1 = 0 (with carry)
        A = 4'b1111; B = 4'b0001; sel = 3'b000; #10;
       $finish;
    end
endmodule

//Output
Time	   A	   B	   sel	  Result	  CarryOut	  Zero
0	      0100	0011	   000	  0111	       0	      	0
10000	  0101	0010	   001	  0011	       1		    0
20000	  1100	1010	   010	  1000	       0		    0
30000	  1100	1010	   011	  1110	       0		    0
40000	  0011	0011       001	  0000	       1		    1
50000	  1111	0001	   000	  0000	       1		    1
testbench.sv:46: $finish called at 60000 (1ps)
