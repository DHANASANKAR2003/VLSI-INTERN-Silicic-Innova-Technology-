13. Implement an even and odd parity generator.
// Design code
`timescale 1ns/1ps

module parity_generator(
  input [3:0]data_in,
  output even_parity,
  output odd_parity
);
  
  assign even_parity = ~^data_in;
  assign odd_parity = ^data_in;
endmodule 

// Testbench code
`timescale 1ns/1ps

module parity_generator_tb;
  reg [3:0]data_in;
  wire even_parity;
  wire odd_parity;
  
  parity_generator dut(
    .data_in(data_in),
    .even_parity(even_parity),
    .odd_parity(odd_parity));
  
  initial begin
    $display("TIME\tDTATA\tEVEN PARITY\tODD PARITY");
    $monitor("%0t\t%b\t%b\t\t%b",$time,data_in,even_parity,odd_parity);
    
    data_in = 4'b0000;#10;
    data_in = 4'b0001;#10;
    data_in = 4'b0010;#10;
    data_in = 4'b0011;#10;
    data_in = 4'b0100;#10;
    data_in = 4'b0101;#10;
    data_in = 4'b0110;#10;
    data_in = 4'b0111;#10;
    data_in = 4'b1000;#10;
    data_in = 4'b1001;#10;
    data_in = 4'b1010;#10;
    data_in = 4'b1011;#10;
    data_in = 4'b1100;#10;
    data_in = 4'b1101;#10;
    data_in = 4'b1110;#10;
  end
endmodule
    
OUTPUT
TIME	 DTATA	 EVEN PARITY	ODD PARITY
0	     0000	        1		       0
10	   0001	        0		       1
20	   0010	        0		       1
30	   0011	        1		       0
40	   0100	        0		       1
50	   0101	        1		       0
60	   0110	        1		       0
70	   0111	        0		       1
80	   1000	        0		       1
90	   1001	        1		       0
100	   1010	        1		       0
110	   1011	        0		       1
120	   1100	        1		       0
130	   1101	        0		       1
140	   1110	        0		       1
150	   1111	        1		       0
