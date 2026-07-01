// Design code 
module t_ff_to_sr_ff(
  input s, r, clk, rst,
  output reg q,
  output qn
);

  wire t;

  assign qn = ~q;

  // SR to T conversion:
  assign t = (s & ~r) ? 1'b1 :     // Set → Toggle if Q=0
             (~s & r) ? 1'b1 :     // Reset → Toggle if Q=1
             (s & r) ? 1'bx :      // Invalid
             1'b0;                 // Hold

  always @(posedge clk or posedge rst) begin
    if (rst)
      q <= 0;
    else if (t === 1'bx)
      q <= 1'bx;
    else if (t)
      q <= ~q;
    else
      q <= q;
  end

endmodule

//Testbench code
module t_ff_to_sr_ff_tb;
  reg s,r,clk,rst;
  wire q,qn;
  
  t_ff_to_sr_ff uut(s,r,clk,rst,q,qn);
  
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
    s = 1; r = 1;#10;
    s = 0; r = 0;#10;
    s = 1; r = 0;#10;
    s = 0; r = 1;#10;
    $finish;
  end
  initial begin
    $dumpfile("t_ff_to_sr_ff.vcd");
    $dumpvars(1,t_ff_to_sr_ff_tb);
  end
  initial begin
    $monitor(" | Time = %0t | \t CLK = %b | RST = %b | S = %b | R = %b |Q = %b | QN = %b |",$time,clk,rst,s,r,q,qn);
  end
endmodule
