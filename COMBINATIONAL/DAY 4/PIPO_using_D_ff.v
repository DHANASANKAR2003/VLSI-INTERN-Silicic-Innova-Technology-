//Design code
module pipo(
  input [3:0] d,
  input clk,rst,load,
  output reg [3:0]q,
  output qn);
  
  assign qn = ~q;	
  
  always@(posedge clk or posedge rst) begin
    if(rst)
      q <= 4'b0000;
    else if(load == 1)
      q <= d;
    else
      q <= q;
  end
endmodule


//testbench code
module pipo_tb();
  reg [3:0]d;
  reg clk,rst,load;
  wire [3:0]q;
  wire qn;
  
  pipo uut(d,clk,rst,load,q,qn);
  
  initial begin
    clk = 0;
    forever #5clk = ~clk;
  end
  initial begin
    rst = 1; load = 0; d = 4'b0000;#10;
    rst = 0;
    
    load = 1; d = 4'b1010;#10;
    load = 0;#10;
    load = 1; d = 4'b0101;#10;
    load = 0;#10;
    
    $finish;
  end
  initial begin
    $dumpfile("pipo.vcd");
    $dumpvars(1,pipo_tb);
  end
  initial begin
    $monitor("Time = %0t \t CLK = %b RST = %b LOAD = %b D = %b Q = %b QN = %b",$time,clk,rst,load,d,q,qn );
  end
endmodule
  
