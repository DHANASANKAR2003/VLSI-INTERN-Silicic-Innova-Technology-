module sr_ff_to_d_ff(
  input d,clk,rst,
  output reg q,
  output qn);
  
  wire s,r;
  
  assign qn = ~q;
  assign s = d;
  assign r = ~d;
  
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        q <= 0;
      else 
        case({s,r})
          2'b00:q <= q;
          2'b01:q <= 0;
          2'b10:q <= 1;
          2'b11:q <= 1'bx;
        endcase
      end

endmodule
      
//Testbench code
module sr_ff_to_d_ff_tb;
  reg d,clk,rst;
  wire q,qn;
  
  sr_ff_to_d_ff uut(d,clk,rst,q,qn);
  
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
    $dumpfile("sr_ff_to_d_ff.vcd");
    $dumpvars(1,sr_ff_to_d_ff_tb);
  end
  initial begin
    $monitor(" | Time = %0t | \t CLK = %b | RST = %b | D = %b | Q = %b | QN = %b |",$time,clk,rst,d,q,qn);
  end
endmodule
