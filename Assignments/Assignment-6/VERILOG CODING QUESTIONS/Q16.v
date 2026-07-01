16. Implement a 4-bit look-ahead carry generator.
//Design Code
module lookahead_carry_4bit (
  input  [3:0] P,  
  input  [3:0] G,  
  input        Cin, 
  output [3:1] C,  
  output       Cout,
  output       PG,  
  output       GG 
);

  
  assign C[1] = G[0] | (P[0] & Cin);
  assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & Cin);
  assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & Cin);
  assign Cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) |
                (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & Cin);

 
  assign GG = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) |
              (P[3] & P[2] & P[1] & G[0]);
  assign PG = P[3] & P[2] & P[1] & P[0];

endmodule

//Testbench code
`timescale 1ns/1ps

`timescale 1ns/1ps

module tb_lookahead_carry_4bit;

  reg [3:0] A, B;        
  reg       Cin;        
  wire [3:0] P, G;
  wire [3:1] C;          
  wire       Cout;       
  wire       PG, GG;    


  assign P = A ^ B;
  assign G = A & B;


  lookahead_carry_4bit uut (
    .P(P),
    .G(G),
    .Cin(Cin),
    .C(C),
    .Cout(Cout),
    .PG(PG),
    .GG(GG)
  );

  initial begin
    $display("Time\t A\t B\tCin\tP\tG\tC\tCout\tPG\tGG");
    $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b",
              $time, A, B, Cin, P, G, C, Cout, PG, GG);

    A = 4'b0000; B = 4'b0000; Cin = 0; #10;
    A = 4'b0001; B = 4'b0001; Cin = 0; #10;
    A = 4'b0011; B = 4'b0101; Cin = 1; #10;
    A = 4'b1111; B = 4'b0001; Cin = 1; #10;
    A = 4'b1010; B = 4'b0101; Cin = 0; #10;
    A = 4'b1100; B = 4'b1100; Cin = 1; #10;
    A = 4'b1111; B = 4'b1111; Cin = 1; #10;

    $finish;
  end

endmodule

OUTPUT
Time	     A	   B	 Cin	   P	   G	  C	  Cout	PG	GG
0	        0000	0000	0	   0000	 0000	 000	 0	   0	0
10000	    0001	0001	0	   0000	 0001	 001	 0	   0	0
20000	    0011	0101	1	   0110	 0001	 111	 0	   0	0
30000	    1111	0001	1	   1110	 0001	 111	 1	   0	1
40000	    1010	0101	0	   1111	 0000	 000	 0	   1	0
50000	    1100	1100	1	   0000	 1100	 100	 1	   0	1
60000	    1111	1111	1	   0000	 1111	 111	 1	   0	1
