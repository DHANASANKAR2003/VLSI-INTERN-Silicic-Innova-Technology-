17. Implement a bit-slice ALU with AND, OR, ADD, SUB.
//Design Code
module bit_slice_alu (
  input  wire a,      
  input  wire b,         
  input  wire cin,     
  input  wire [1:0] sel, 
  output wire result,    
  output wire cout    
);

  wire and_out, or_out, sum, sub;
  wire b_sub, cout_add;

  assign and_out = a & b;
  assign or_out  = a | b;


  assign sum = a ^ b ^ cin;
  assign cout_add = (a & b) | (a & cin) | (b & cin);


  assign b_sub = ~b;
  wire sub_result = a ^ b_sub ^ cin;
  wire cout_sub = (a & b_sub) | (a & cin) | (b_sub & cin);

  assign result = (sel == 2'b00) ? and_out :
                  (sel == 2'b01) ? or_out  :
                  (sel == 2'b10) ? sum     :
                                  sub_result;

  assign cout = (sel == 2'b10) ? cout_add :
                (sel == 2'b11) ? cout_sub : 1'b0;

endmodule

//Testbench code
`timescale 1ns/1ps

module bit_slice_alu_tb;

  reg a, b, cin;
  reg [1:0] sel;
  wire result, cout;

  bit_slice_alu uut (
    .a(a),
    .b(b),
    .cin(cin),
    .sel(sel),
    .result(result),
    .cout(cout)
  );

  initial begin
    $display("Time\tA B Cin Sel Result Cout");
    $monitor("%0t\t%b %b  %b   %b    %b      %b", $time, a, b, cin, sel, result, cout);

  
    sel = 2'b00; 
    cin = 0;
    a = 0; b = 0; #10;
    a = 0; b = 1; #10;
    a = 1; b = 0; #10;
    a = 1; b = 1; #10;

  
    sel = 2'b01; 
    cin = 0;
    a = 0; b = 0; #10;
    a = 0; b = 1; #10;
    a = 1; b = 0; #10;
    a = 1; b = 1; #10;


    sel = 2'b10;
    a = 0; b = 0; cin = 0; #10;
    a = 1; b = 0; cin = 0; #10;
    a = 1; b = 1; cin = 0; #10;
    a = 1; b = 1; cin = 1; #10;


    sel = 2'b11;
    a = 0; b = 0; cin = 1; #10;  
    a = 1; b = 0; cin = 1; #10;  
    a = 1; b = 1; cin = 1; #10;  
    a = 0; b = 1; cin = 1; #10;  

    $finish;
  end

endmodule

OUTPUT
Time	  A B Cin  Sel Result Cout
0	      0 0  0   00    0      0
10000	  0 1  0   00    0      0
20000	  1 0  0   00    0      0
30000	  1 1  0   00    1      0
40000	  0 0  0   01    0      0
50000	  0 1  0   01    1      0
60000	  1 0  0   01    1      0
70000	  1 1  0   01    1      0
80000	  0 0  0   10    0      0
90000	  1 0  0   10    1      0
100000	1 1  0   10    0      1
110000	1 1  1   10    1      1
120000	0 0  1   11    0      1
130000	1 0  1   11    1      1
140000	1 1  1   11    0      1
150000	0 1  1   11    1      0
