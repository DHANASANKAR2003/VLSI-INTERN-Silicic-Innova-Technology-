25. Implement a 4-bit subtractor using an adder.
//Design Code
module subtractor_4bit (
  input  [3:0] A, B,
  output [3:0] Diff,
  output Cout  
);
  wire [3:0] B_comp;   
  wire       Cin = 1; 

  assign B_comp = ~B;

  wire [4:0] temp_sum;  

  assign temp_sum = A + B_comp + Cin;

  assign Diff = temp_sum[3:0];
  assign Cout = temp_sum[4];

endmodule
//Testbench code
module tb_subtractor_4bit;

  reg [3:0] A, B;
  wire [3:0] Diff;
  wire Cout;

  subtractor_4bit uut (
    .A(A), 
    .B(B), 
    .Diff(Diff), 
    .Cout(Cout)
  );

  initial begin
    $display("Time\tA\tB\tDiff\tCout");
    $monitor("%0t\t%b\t%b\t%b\t%b", $time, A, B, Diff, Cout);

    A = 4'b0110; B = 4'b0011; #10;  
    A = 4'b0100; B = 4'b0101; #10;  
    A = 4'b1111; B = 4'b1111; #10;  
    A = 4'b1001; B = 4'b0001; #10;  
    A = 4'b0000; B = 4'b0001; #10;  

    $finish;
  end

endmodule

OUTPUT
Time	A	   B	  Diff	Cout
0	  0110	0011	0011	1
10	0100	0101	1111	0
20	1111	1111	0000	1
30	1001	0001	1000	1
40	0000	0001	1111	0
