module d_ff_to_t_ff(
  input t,clk,rst,
  output reg q,
  output qn);
  
  wire d;
  
  assign qn = ~q;
  assign d = q ^ t;
  
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        q <= 0;
      else
        q <= d;
    end
endmodule
      
// Code your testbench here
module d_ff_to_t_ff_tb;
  reg t,clk,rst;
  wire q,qn;
  
  d_ff_to_t_ff uut(t,clk,rst,q,qn);
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    rst = 1; t = 0;#10;
    rst = 0;
    t = 1;#10;
    t = 0;#10;
    t = 0;#10;
    t = 1;#10;
    t = 0;#10;
    t = 1;#10;
    t = 0;#10;
   
    $finish;
  end
  initial begin
    $dumpfile("d_ff_to_t_ff.vcd");
    $dumpvars(1,d_ff_to_t_ff_tb);
  end
  initial begin
    $monitor(" | Time = %0t | \t CLK = %b | RST = %b | T = %b | Q = %b | QN = %b |",$time,clk,rst,t,q,qn);
  end
endmodule
    
