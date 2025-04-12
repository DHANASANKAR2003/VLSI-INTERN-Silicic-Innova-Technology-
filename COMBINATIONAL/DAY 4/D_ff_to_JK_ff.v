// Design code 
module d_ff_to_jk_ff(
  input k,j,clk,rst,
  output reg q,
  output qn);
  
  wire d,and1,and2,not1;
  
  assign qn = ~q;
  assign d = ((qn & j)|(~k & q));
  
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        q <= 0;
      else 
        q <= d;
    end
endmodule
      
//Testbench code
module d_ff_to_jk_ff_tb;
  reg k,j,clk,rst;
  wire q,qn;
  
  d_ff_to_jk_ff uut(k,j,clk,rst,q,qn);
  
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
    $dumpfile("d_ff_to_jk_ff.vcd");
    $dumpvars(1,d_ff_to_jk_ff_tb);
  end
  initial begin
    $monitor(" | Time = %0t | \t CLK = %b | RST = %b | J = %b | K = %b | Q = %b | QN = %b |",$time,clk,rst,j,k,q,qn);
  end
endmodule
