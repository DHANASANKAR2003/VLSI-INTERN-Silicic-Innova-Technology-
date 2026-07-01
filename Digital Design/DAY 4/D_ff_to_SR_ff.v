module d_ff_to_sr_ff(
  input s,r,clk,rst,
  output reg q,
  output qn);
  
  wire d,nand1,not1;
  
  assign qn = ~q;
  assign d = (s & ~r) ? 1'b1 :         // Set
           (~s & r) ? 1'b0 :         // Reset
           (s & r) ? 1'bx :          // Invalid
           q;                       // Hold (s = 0, r = 0)

  
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        q <= 0;
      else 
        q <= d;
    end
endmodule

//Testbench code
module d_ff_to_sr_ff_tb;
  reg s,r,clk,rst;
  wire q,qn;
  
  d_ff_to_sr_ff uut(s,r,clk,rst,q,qn);
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    rst = 1; s = 0; r = 1;#10;
    rst = 0;
    s = 1; r = 0;#10;
    s = 0; r = 0;#10;
    s = 0; r = 1;#10;
    s = 1; r = 1;#10;
    s = 0; r = 0;#10;
    s = 1; r = 0;#10;
    s = 0; r = 1;#10;
   
    $finish;
  end
  initial begin
    $dumpfile("d_ff_to_sr_ff.vcd");
    $dumpvars(1,d_ff_to_sr_ff_tb);
  end
  initial begin
    $monitor(" | Time = %0t | \t CLK = %b | RST = %b | S = %b | R = %b | Q = %b | QN = %b |",$time,clk,rst,s,r,q,qn);
  end
endmodule
