//Design Code
module fa_using_hf(
  input a,b,
  output s,c
);
  assign s = a^b;
  assign c = (a&b);
endmodule

module fa(
  input a,b,cin,
  output s,cout);
  
  wire sum1, carry1, carry2;
  
  fa_using_hf hf1(a,b,sum1,carry1);
  
  fa_using_hf hf2(sum1,cin,s,carry2);
  
  assign cout = carry1|carry2;
  
endmodule

module full_adder_tb;
  reg a,b,cin;
  wire s,cout;
  
  fa uut(a,b,cin,s,cout);
  
  initial begin
    
    a = 1'b0; b = 1'b0; cin = 1'b0;#10;
    a = 1'b0; b = 1'b0; cin = 1'b1;#10;
    a = 1'b0; b = 1'b1; cin = 1'b0;#10;
    a = 1'b0; b = 1'b1; cin = 1'b1;#10;
    a = 1'b1; b = 1'b0; cin = 1'b0;#10;
    a = 1'b1; b = 1'b0; cin = 1'b1;#10;
    a = 1'b1; b = 1'b1; cin = 1'b0;#10;
    a = 1'b1; b = 1'b1; cin = 1'b1;#10;
    
    $finish;
  end
  initial begin
    $dumpfile("fa.vcd");
    $dumpvars(1,full_adder_tb);
  end
  initial begin
    $monitor("Time = %0t \t  INPUT A = %b B = %b Cin = %b | OUTPUT  SUM = %b CARRY = %b",$time,a,b,cin,s,cout);
  end
endmodule
