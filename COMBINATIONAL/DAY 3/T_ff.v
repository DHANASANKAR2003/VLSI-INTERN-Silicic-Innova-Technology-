//Design Code
module t_ff(
  input t,rst,clk,
  output reg q,qn);
  
  assign qn = ~q;
  
  always@(posedge clk or posedge rst)begin
    if(rst)
      q <= 0;
    else
      q <= ~t;
  end
endmodule

//Testbench code

module t_ff_tb;
  reg t,rst,clk;
  wire q,qn;
  
  t_ff uut(t,rst,clk,q,qn);
  
  initial begin
    clk = 0;
    forever #5clk = ~clk;
  end
  
  initial begin
    clk = 1;#5; rst = 1; t = 0;#10;
    rst = 0; t = 0;#10;
    t = 1;#10;
    rst = 0; t = 1;#10;
    t = 0;#10;
    clk = 0;#5; rst = 1; t = 0;#10;
    rst = 0; t = 0;#10;
    t = 1;#10;
    rst = 0; t = 1;#10;
    t = 0;#10;
    $finish;
  end
  initial begin
    $dumpfile("t_ff.vcd");
    $dumpvars(1,t_ff_tb);
  end
  initial begin
    $monitor("Time = %0t \t CLK = %b RST = %b T = %b Q = %b QN = %b",$time,clk,rst,t,q,qn);
  end
endmodule
    
