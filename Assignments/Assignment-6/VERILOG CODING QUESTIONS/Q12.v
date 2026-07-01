12. Implement an 8-bit comparator using 4-bit comparators.
// Design code
module comparator_4bit (
    input [3:0] A, B,
    output A_gt_B, A_eq_B, A_lt_B
);
    assign A_gt_B = (A > B);
    assign A_eq_B = (A == B);
    assign A_lt_B = (A < B);
endmodule

module comparator_8bit (
    input [7:0] A, B,
    output A_gt_B, A_eq_B, A_lt_B
);
    wire high_gt, high_eq, high_lt;
    wire low_gt, low_eq, low_lt;

    comparator_4bit cmp_high (
        .A(A[7:4]), .B(B[7:4]),
        .A_gt_B(high_gt), .A_eq_B(high_eq), .A_lt_B(high_lt)
    );

    comparator_4bit cmp_low (
        .A(A[3:0]), .B(B[3:0]),
        .A_gt_B(low_gt), .A_eq_B(low_eq), .A_lt_B(low_lt)
    );

    assign A_gt_B = high_gt | (high_eq & low_gt);
    assign A_eq_B = high_eq & low_eq;
    assign A_lt_B = high_lt | (high_eq & low_lt);
endmodule

// Testbench code
`timescale 1ns/1ps

module comparator_8bit_tb;
    reg [7:0] A, B;
    wire A_gt_B, A_eq_B, A_lt_B;
  
    comparator_8bit dut (
        .A(A),
        .B(B),
        .A_gt_B(A_gt_B),
        .A_eq_B(A_eq_B),
        .A_lt_B(A_lt_B)
    );

    initial begin
        $display("Time\tA\t\tB\t\tA>B\tA==B\tA<B");
        $monitor("%0t\t%8b\t%8b\t%b\t%b\t%b", 
                  $time, A, B, A_gt_B, A_eq_B, A_lt_B);

        A = 8'b11000001; B = 8'b10111111; #10;

    
        A = 8'b01101010; B = 8'b01101010; #10;

      
        A = 8'b00110011; B = 8'b01000000; #10;


        A = 8'b10001100; B = 8'b10001011; #10;


        A = 8'b00001111; B = 8'b00100000; #10;
        $finish;
    end
endmodule

OUTPUT
Time	   A		     B		   A>B	A==B	A<B
0	    11000001	10111111	  1	   0	   0
10000	01101010	01101010	  0	   1	   0
20000	00110011	01000000	  0	   0	   1
30000	10001100	10001011	  1	   0	   0
40000	00001111	00100000	  0	   0	   1
