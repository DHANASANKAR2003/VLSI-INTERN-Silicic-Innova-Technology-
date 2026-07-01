15. Design a 4-bit barrel shifter (left and right).
//Design Code
module barrel_shifter_4bit (
  input  [3:0] data_in,     
  input  [1:0] shift_amt,  
  input        dir,        
  output [3:0] data_out     
);
  assign data_out = (dir == 0) ? (data_in << shift_amt) | (data_in >> (4 - shift_amt)) :
                                  (data_in >> shift_amt) | (data_in << (4 - shift_amt));
endmodule

//Testbench code
`timescale 1ns/1ps

module tb_barrel_shifter_4bit;

  reg  [3:0] data_in;
  reg  [1:0] shift_amt;
  reg        dir;
  wire [3:0] data_out;

  barrel_shifter_4bit uut (
    .data_in(data_in),
    .shift_amt(shift_amt),
    .dir(dir),
    .data_out(data_out)
  );

  initial begin
    $display("Time\tDir\tShift\tInput\tOutput");
    $monitor("%0t\t%b\t%d\t%b\t%b", $time, dir, shift_amt, data_in, data_out);

    data_in = 4'b1011;

    dir = 0; 
    shift_amt = 2'd0; #10;
    shift_amt = 2'd1; #10;
    shift_amt = 2'd2; #10;
    shift_amt = 2'd3; #10;

    dir = 1; 
    shift_amt = 2'd0; #10;
    shift_amt = 2'd1; #10;
    shift_amt = 2'd2; #10;
    shift_amt = 2'd3; #10;

    $finish;
  end
endmodule

OUTPUT
Time	Dir	Shift	Input	Output
0	     0	  0	  1011	1011
10000	 0	  1	  1011	0111
20000	 0	  2	  1011	1110
30000	 0	  3	  1011	1101
40000	 1	  0	  1011	1011
50000	 1	  1	  1011	1101
60000	 1	  2	  1011	1110
70000	 1	  3	  1011	0111
