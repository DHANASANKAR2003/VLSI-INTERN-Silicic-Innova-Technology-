14. Implement an even and odd parity checker.
  // Design code
module parity_generator(
  input [3:0]data_in,
  input parity_bit,
  output even_parity,
  output odd_parity
);
  assign total_parity = ^{data_in,parity_bit};
  assign even_parity = ~total_parity;
  assign odd_parity = total_parity;
endmodule 

// Testbench code
module parity_generator_tb;
  reg [3:0]data_in;
  reg parity_bit;
  wire even_parity;
  wire odd_parity;
  
  parity_generator dut(
    .data_in(data_in),
    .parity_bit(parity_bit),
    .even_parity(even_parity),
    .odd_parity(odd_parity));
  
  initial begin
    $display("TIME\tDTATA\tPARITY BIT\tEVEN PARITY\tODD PARITY");
    $monitor("%0t\t%b\t\t%b\t%b\t\t%b",$time,data_in,parity_bit,even_parity,odd_parity);
    
    data_in = 4'b0000; parity_bit = 1'b0;#10;
    data_in = 4'b0001; parity_bit = 1'b1;#10;
    data_in = 4'b0010; parity_bit = 1'b0;#10;
    data_in = 4'b0011; parity_bit = 1'b1;#10;
    data_in = 4'b0100; parity_bit = 1'b0;#10;
    data_in = 4'b0101; parity_bit = 1'b1;#10;
    data_in = 4'b0110; parity_bit = 1'b0;#10;
    data_in = 4'b0111; parity_bit = 1'b1;#10;
    data_in = 4'b1000; parity_bit = 1'b0;#10;
    data_in = 4'b1001; parity_bit = 1'b1;#10;
    data_in = 4'b1010; parity_bit = 1'b0;#10;
    data_in = 4'b1011; parity_bit = 1'b1;#10;
    data_in = 4'b1100; parity_bit = 1'b0;#10;
    data_in = 4'b1101; parity_bit = 1'b1;#10;
    data_in = 4'b1110; parity_bit = 1'b0;#10;
    data_in = 4'b1111; parity_bit = 1'b1;#10;
    $finish;
  end
    
endmodule
    
OUTPUT
TIME	DTATA	PARITY BIT	EVEN PARITY	ODD PARITY
0	    0000		0	           1		        0
10	  0001		1	           1		        0
20	  0010		0	           0		        1
30	  0011		1	           0		        1
40	  0100		0	           0		        1
50	  0101		1	           0		        1
60	  0110		0	           1		        0
70	  0111		1	           1		        0
80	  1000		0	           0		        1
90	  1001		1	           0		        1
100	  1010		0	           1		        0
110	  1011		1            1		        0
120	  1100		0	           1		        0
130	  1101		1	           1		        0
140	  1110		0	           0		        1
150	  1111		1	           0		        1
