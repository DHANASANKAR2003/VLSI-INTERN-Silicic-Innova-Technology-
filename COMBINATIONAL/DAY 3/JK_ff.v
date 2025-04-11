// Code your design here
module jk_ff(
  input j,k,rst,clk,
  output reg q,qn);
  
  assign qn = ~q;
  
  always@(posedge clk or posedge rst)begin
    if(rst)
      q <= 0;
    else 
      begin
        case({j,k})
          2'b00:q <= 1'bx;
          2'b01:q <= 0;
          2'b10:q <= 1;
          2'b11:q <= q;
        endcase
      end
  end
        
endmodule

// Code your testbench here
module jk_ff_tb;
  reg j,k,rst,clk;
  wire q,qn;
  
  jk_ff uut(j,k,rst,clk,q,qn);
  
  initial begin
    clk = 0;
    forever #5clk = ~clk;
  end
  
  initial begin
    rst = 1; j = 0; k = 1;#10;
    rst = 0; j = 1; k = 0;#10;
    j = 0; k = 0; #10;
    rst = 1; j = 1; k = 1; #10;
    j = 1; k = 0;#10;
    rst = 1; j = 0; k = 1;#10;
    rst = 0; j = 1; k = 0;#10;
    j = 0; k = 0; #10;
    rst = 0; j = 1; k = 1;#10;
    j = 1; k = 0;#10;
    $finish;
  end
  initial begin
    $dumpfile("jk_ff.vcd");
    $dumpvars(1,jk_ff_tb);
  end
  initial begin
    $monitor(" | Time = %0t | \t CLK = %b | RST = %b | J = %b | K = %b | Q = %b | QN = %b |",$time,clk,rst,j,k,q,qn);
  end
endmodule
    
