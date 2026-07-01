2. Implement a 2:1 multiplexer using the ? operator.

//Design Code 
module mux_2_1(
  input a,b,
  input sel,
  output reg out
);
  
  assign out = sel ? a: b;
endmodule 

//tetbench code
module mux_2_1_tb;
  reg a,b;
  reg sel;
  wire out;
  
  mux_2_1 dut(
    .a(a),
    .b(b),
    .sel(sel),
    .out(out));
  
  initial begin 
    $display("Time\tSel\tA\tB\tY");
       
    a = 0; b = 0; sel = 0; #10;
    $display("%0t\t%b\t%b\t%b\t%b", $time, sel, a, b, out);

    a = 0; b = 1; sel = 0; #10;
    $display("%0t\t%b\t%b\t%b\t%b", $time, sel, a, b, out);

    a = 1; b = 0; sel = 0; #10;
    $display("%0t\t%b\t%b\t%b\t%b", $time, sel, a, b, out);

    a = 1; b = 1; sel = 0; #10;
    $display("%0t\t%b\t%b\t%b\t%b", $time, sel, a, b, out);

    a = 0; b = 0; sel = 1; #10;
    $display("%0t\t%b\t%b\t%b\t%b", $time, sel, a, b, out);

    a = 0; b = 1; sel = 1; #10;
    $display("%0t\t%b\t%b\t%b\t%b", $time, sel, a, b, out);

    a = 1; b = 0; sel = 1; #10;
    $display("%0t\t%b\t%b\t%b\t%b", $time, sel, a, b, out);

    a = 1; b = 1; sel = 1; #10;
    $display("%0t\t%b\t%b\t%b\t%b", $time, sel, a, b, out);

    $finish;
  end
endmodule 

OUTPUT
Time	Sel	A	B	Y
10	   0	0	0	0
20	   0	0	1	1
30	   0	1	0	0
40	   0	1	1	1
50	   1	0	0	0
60	   1	0	1	0
70	   1	1	0	1
80	   1	1	1	1
