// Design code 
module jk_ff_to_sr_ff(
  input s,r,clk,rst,
  output reg q,
  output qn);
  
  wire j,k;
  
  assign qn = ~q;
  assign j = s;
  assign k = r; 
  
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        q <= 0;
      else 
        begin
          case({j,k})
          2'b00:q <= q;
          2'b01:q <= 0;
          2'b10:q <= 1;
          2'b11:q <= 1'bx;
        endcase
        end
    end

endmodule
      
//Testbench code
module jk_ff_to_sr_ff_tb;
  reg s,r,clk,rst;
  wire q,qn;
  
  jk_ff_to_sr_ff uut(s,r,clk,rst,q,qn);
  
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
    $dumpfile("jk_ff_to_sr_ff.vcd");
    $dumpvars(1,jk_ff_to_sr_ff_tb);
  end
  initial begin
    $monitor(" | Time = %0t | \t CLK = %b | RST = %b | S = %b | R = %b | Q = %b | QN = %b |",$time,clk,rst,s,r,q,qn);
  end
endmodule
