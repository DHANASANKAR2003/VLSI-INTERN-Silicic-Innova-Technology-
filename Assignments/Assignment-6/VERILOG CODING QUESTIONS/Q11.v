11. Implement a 4-bit comparator.
//Design code 
module comparator_4bit (
    input  wire [3:0] A,
    input  wire [3:0] B,
    output wire A_gt_B,
    output wire A_lt_B,
    output wire A_eq_B
);

    assign A_gt_B = (A > B);
    assign A_lt_B = (A < B);
    assign A_eq_B = (A == B);

endmodule
//Testbench code
module comparator_4bit_tb;
    reg  [3:0] A, B;
    wire A_gt_B, A_lt_B, A_eq_B;

    comparator_4bit dut (
        .A(A),
        .B(B),
        .A_gt_B(A_gt_B),
        .A_lt_B(A_lt_B),
        .A_eq_B(A_eq_B)
    );

    initial begin
        $display("Time\tA\tB\tA>B\tA<B\tA==B");
        $monitor("%4t\t%b\t%b\t%b\t%b\t%b", $time, A, B, A_gt_B, A_lt_B, A_eq_B);

        A = 4'b0101; B = 4'b0011; #10; 
        A = 4'b0010; B = 4'b0100; #10;  
        A = 4'b1001; B = 4'b1001; #10;  
        A = 4'b1111; B = 4'b0000; #10; 
        A = 4'b0000; B = 4'b1111; #10;  
        A = 4'b0110; B = 4'b0110; #10;  

        $finish;
    end
endmodule
OUTPUT
Time	  A	    B	 A>B  A<B	 A==B
   0	0101	0011	1  	 0	   0
  10	0010	0100	0	   1	   0
  20	1001	1001	0	   0	   1
  30	1111	0000	1	   0	   0
  40	0000	1111	0	   1	   0
  50	0110	0110	0	   0	   1
