// Design code 
module sr_ff_to_jk_ff(
  input j,k,clk,rst,
  output reg q,
  output qn);
  
  wire s,r;
  
  assign qn = ~q;
  assign s = j & ~q;
  assign r = k & q;
  
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
module sr_ff_to_jk_ff_tb;
  reg j,k,clk,rst;
  wire q,qn;
  
  sr_ff_to_jk_ff uut(j,k,clk,rst,q,qn);
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    rst = 1; j = 0; k = 1;#10;
    rst = 0;
    j = 1; k = 0;#10;
    j = 0; k = 0;#10;
    j = 0; k = 1;#10;
    j = 1; k = 1;#10;
    j = 0; k = 0;#10;
    j = 1; k = 0;#10;
    j = 0; k = 1;#10;
   
    $finish;
  end
  initial begin
    $dumpfile("sr_ff_to_jk_ff.vcd");
    $dumpvars(1,sr_ff_to_jk_ff_tb);
  end
  initial begin
    $monitor(" | Time = %0t | \t CLK = %b | RST = %b | J = %b | K = %b | Q = %b | QN = %b |",$time,clk,rst,j,k,q,qn);
  end
endmodule
