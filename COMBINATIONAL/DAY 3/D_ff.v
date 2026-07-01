// Code your design here
module d_ff(
  input d,rst,clk,
  output reg q,qn);
  
  assign qn = ~q;
  
  always@(posedge clk or posedge rst)begin
    if(rst)
      q <= 0;
    else
      q <= d;
  end
endmodule

// Code your testbench here
// or browse Examples
module d_ff_tb;
  reg d,rst,clk;
  wire q,qn;
  
  d_ff uut(d,rst,clk,q,qn);
  
  initial begin
    clk = 0;
    forever #5clk = ~clk;
  end
  
  initial begin
    clk = 1;#5; rst = 1; d = 0;#10;
    rst = 0; d = 0;#10;
    d = 1;#10;
    rst = 0; d = 1;#10;
    d = 0;#10;
    clk = 0;#5; rst = 1; d = 0;#10;
    rst = 0; d = 0;#10;
    d = 1;#10;
    rst = 1; d = 1;#10;
    d = 0;#10;
    $finish;
  end
  initial begin
    $dumpfile("d_ff.vcd");
    $dumpvars(1,d_ff_tb);
  end
  initial begin
    $monitor("Time = %0t \t CLK = %b RST = %b D = %b Q = %b QN = %b",$time,clk,rst,d,q,qn);
  end
endmodule
    
