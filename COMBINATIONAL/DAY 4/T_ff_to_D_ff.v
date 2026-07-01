// Design code 
module t_ff_to_d_ff(
  input d,clk,rst,
  output reg q,
  output qn);
  
  wire t;
  
  assign qn = ~q;
  assign t = d ^ q;  
  
  always@(posedge clk or posedge rst)
    begin
      if (rst)
      q <= 0;
      else if (t)
        q <= ~q;  // Toggle
      else
        q <= q;   // Hold
  end

endmodule
      
//Testbench code
module t_ff_to_d_ff_tb;
  reg d,clk,rst;
  wire q,qn;
  
  t_ff_to_d_ff uut(d,clk,rst,q,qn);
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    rst = 1; d = 0;#10;
    rst = 0;
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
    $dumpfile("t_ff_to_d_ff.vcd");
    $dumpvars(1,t_ff_to_d_ff_tb);
  end
  initial begin
    $monitor(" | Time = %0t | \t CLK = %b | RST = %b | D = %b| Q = %b | QN = %b |",$time,clk,rst,d,q,qn);
  end
endmodule
