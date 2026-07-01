// Code your design here
module sr_ff(
  input s,r,rst,clk,
  output reg q,qn);
  
  assign qn = ~q;
  
  always@(posedge clk or posedge rst)begin
    if(rst)
      q <= 0;
    else 
      begin
        case({s,r})
          2'b00:q <= q;
          2'b01:q <= 0;
          2'b10:q <= 1;
          2'b11:q <= 1'bx;
        endcase
      end
  end
        
endmodule

// Code your testbench here
module sr_ff_tb;
  reg s,r,rst,clk;
  wire q,qn;
  
  sr_ff uut(s,r,rst,clk,q,qn);
  
  initial begin
    clk = 0;
    forever #5clk = ~clk;
  end
  
  initial begin
    rst = 1; s = 0; r = 1;#10;
    rst = 0; s = 1; r = 0;#10;
    s = 0; r = 0; #10;
    rst = 0; s = 1; r = 1; #10;
    s = 1; r = 0;#10;
    rst = 1; s = 0; r = 1;#10;
    rst = 0; s = 1; r = 0;#10;
    s = 0; r = 0; #10;
    rst = 0; s = 1; r = 1;#10;
    s = 1; r = 0;#10;
    $finish;
  end
  initial begin
    $dumpfile("sr_ff.vcd");
    $dumpvars(1,sr_ff_tb);
  end
  initial begin
    $monitor("Time = %0t \t CLK = %b RST = %b S = %b R = %b Q = %b QN = %b",$time,clk,rst,s,r,q,qn);
  end
endmodule
    
