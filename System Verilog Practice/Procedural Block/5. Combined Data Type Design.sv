//DESIGN
module all_blocks_dt (
  input  logic clk, reset,
  input  logic [3:0] a, b,
  input  logic sel,
  output logic [3:0] y, q
);
  logic [3:0] temp;
  logic status;      
  int counter;      

  initial begin
    $display("Simulation started at time %0t", $time);
  end

  always_comb begin
    if (sel)
      temp = a + b;
    else
      temp = a - b;
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      q       <= 0;
      counter <= 0;
      status  <= 0;
    end else begin
      q       <= temp;
      counter <= counter + 1;
      status  <= 1;
    end
  end

  always_comb begin
    y = q ^ a;
  end
endmodule


//TESTBENCH

`timescale 1ns/1ps

module tb_all_blocks_dt;
  logic clk, reset;
  logic [3:0] a, b;
  logic sel;
  logic [3:0] y, q;

  all_blocks_dt dut (
    .clk(clk),
    .reset(reset),
    .a(a),
    .b(b),
    .sel(sel),
    .y(y),
    .q(q)
  );	

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $dumpfile("all_blocks.vcd");
    $dumpvars(0, tb_all_blocks_dt);
    $display("Time\tclk\t\treset\tsel\ta\tb\tq\ty");
    $monitor("%0t\t\t%b\t\t%b\t%b\t%0d\t%0d\t%0d\t%0d", 
              $time, clk, reset, sel, a, b, q, y);

    reset = 1; sel = 0; a = 4'd0; b = 4'd0;
    #10; reset = 0;

    sel = 0; a = 4'd10; b = 4'd3; #20;
    sel = 1; a = 4'd5;  b = 4'd2; #20;
    sel = 0; a = 4'd8;  b = 4'd4; #20;

    reset = 1; #10; reset = 0;
    sel = 1; a = 4'd9;  b = 4'd6; #20;

    $display("Simulation Complete at time %0t", $time);
    $finish;
  end
endmodule


OUTPUT

Time	clk		reset	sel	a	b	q	y
0		0		1	0	0	0	0	0
5000		1		1	0	0	0	0	0
10000		0		0	0	10	3	0	10
15000		1		0	0	10	3	7	13
20000		0		0	0	10	3	7	13
25000		1		0	0	10	3	7	13
30000		0		0	1	5	2	7	2
35000		1		0	1	5	2	7	2
40000		0		0	1	5	2	7	2
45000		1		0	1	5	2	7	2
50000		0		0	0	8	4	7	15
55000		1		0	0	8	4	4	12
60000		0		0	0	8	4	4	12
65000		1		0	0	8	4	4	12
70000		0		1	0	8	4	0	8
75000		1		1	0	8	4	0	8
80000		0		0	1	9	6	0	9
85000		1		0	1	9	6	15	6
90000		0		0	1	9	6	15	6
95000		1		0	1	9	6	15	6
