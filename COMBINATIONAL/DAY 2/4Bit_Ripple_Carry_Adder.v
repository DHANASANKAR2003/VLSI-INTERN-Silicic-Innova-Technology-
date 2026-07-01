//design code
module fa(
  input a,b,cin,
  output reg s,cout
);
      assign s = a^b^cin;
      assign cout = ((a&b)|(a&cin)|(b&cin));
endmodule

module rca(
  input [3:0]a,b,
  input Cin,
  output reg [3:0]s,
  output Cout
);
  wire c1,c2,c3;
  
  fa fa1(a[0],b[0],Cin,s[0],c1);
  fa fa2(a[1],b[1],c1,s[1],c2);
  fa fa3(a[2],b[2],c2,s[2],c3);
  fa fa4(a[3],b[3],c3,s[3],Cout);
  
endmodule

module rca_tb();
  reg [3:0]a,b;
  reg Cin;
  wire [3:0]s;
  wire Cout;
  
  rca uut(a,b,Cin,s,Cout);
  
  initial begin
    a = 4'b0001; b = 4'b0010; Cin = 0; #10;
    a = 4'b0100; b = 4'b0011; Cin = 0; #10;
    a = 4'b1111; b = 4'b0001; Cin = 0; #10;
    a = 4'b1010; b = 4'b0101; Cin = 1; #10;
    $finish;
    
  end
  initial begin
    $dumpfile("rcaa.vcd");
    $dumpvars(1,rca_tb);
  end
  initial begin
    $monitor("Time = %0t  \t A = %b  B = %b  Cin = %b  SUM = %b  CARRY = %b",$time,a,b,Cin,s,Cout);
  end
endmodule
