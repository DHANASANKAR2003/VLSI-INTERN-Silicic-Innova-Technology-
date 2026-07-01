//design code
module mux_2to1(
  input a,b,sel,
  output reg c
);
  assign c = sel ? b : a;
endmodule

module fa(
  input a,b,cin,
  output s,cout
);
  assign s = a^b^cin;
  assign cout = ((a&b)|(a&cin)|(b&cin));
endmodule

module rca_add_or_sub(
  input [3:0]a,b,
  input en,
  output [3:0]s,
  output cout
);
  wire [3:0]bin;
  wire c0,c1,c2;
  
  mux_2to1 m0(b[0],~b[0],en,bin[0]);
  mux_2to1 m1(b[1],~b[1],en,bin[1]);
  mux_2to1 m2(b[2],~b[2],en,bin[2]);
  mux_2to1 m3(b[3],~b[3],en,bin[3]);
  
  fa fa1(a[0],bin[0],en,s[0],c0);
  fa fa2(a[1],bin[1],c0,s[1],c1);
  fa fa3(a[2],bin[2],c1,s[2],c2);
  fa fa4(a[3],bin[3],c2,s[3],cout);
  
endmodule
  
  
  
module rca_add_or_sub_tb();
  reg [3:0]a,b;
  reg en;
  wire [3:0]s;
  wire cout;
  
  rca_add_or_sub uut(.a(a),.b(b),.en(en),.s(s),.cout(cout));
  
  initial begin
    en = 1'b1; a = 4'b0001; b = 4'b0010; #10;
    en = 1'b1; a = 4'b0100; b = 4'b0011; #10;
    en = 1'b1; a = 4'b1111; b = 4'b0001; #10;
    en = 1'b1; a = 4'b1010; b = 4'b0101; #10;
    en = 1'b0; a = 4'b0001; b = 4'b0010; #10;
    en = 1'b0; a = 4'b0100; b = 4'b0011; #10;
    en = 1'b0; a = 4'b1111; b = 4'b0001; #10;
    en = 1'b0; a = 4'b1010; b = 4'b0101; #10;
    $finish;
    
  end
  initial begin
    $dumpfile("rca_add_or_sub.vcd");
    $dumpvars(1,rca_add_or_sub_tb);
  end
  initial begin
    $monitor("Time = %0t  \t ENABLE = %b A = %b  B = %b  SUM = %b  CARRY = %b",$time,en,a,b,s,cout);
  end
endmodule
