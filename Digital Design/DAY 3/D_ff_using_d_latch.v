module d_latch(
  input d,en,
  output reg q);
  
  always@(*) begin
    if(en)
      q <= d;
  end
endmodule

module d_latch_us_d_ff(
  input d,clk,
  output q,qn);
  
  wire qm;
  
  d_latch master(.d(d),.en(clk),.q(qm));
  d_latch slave(.d(qm),.en(~clk),.q(q));
  
  assign qn = ~q;
endmodule

module d_latch_us_d_ff_tb;
  reg d,clk;
  wire q,qn;
  
  d_latch_us_d_ff uut(.d(d),.clk(clk),.q(q),.qn(qn));
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    d = 1;#10;
    d = 0;#10;
    d = 0;#10;
    d = 1;#10;
    d = 0;#10;
    d = 1;#10;
    d = 0;#10;
   
    $finish;
  end
  initial begin
    $dumpfile("d_latch_us_d_ff.vcd");
    $dumpvars(1,d_latch_us_d_ff_tb);
  end
  initial begin
    $monitor(" | Time = %0t | \t CLK = %b | d = %b | Q = %b | QN = %b |",$time,clk,d,q,qn);
  end
endmodule
    
