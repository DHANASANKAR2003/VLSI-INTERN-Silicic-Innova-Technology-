//Design code
module piso(
  input [3:0] d,
  input clk,rst,load,
  output reg q,
  output qn);
  
  reg [3:0] shift_reg;
  
  assign qn = ~q;	
  
  always@(posedge clk or posedge rst) begin
    if(rst)
      shift_reg <= 4'b0000;
    else if(load)
      shift_reg <= d;
    else
      shift_reg <= shift_reg << 1; 
  end
  
  always@(*)
    q = shift_reg[3];
  
endmodule


//testbench code
module piso_tb();
  reg [3:0]d;
  reg clk,rst,load;
  wire q;
  wire qn;
  
  piso uut(d,clk,rst,load,q,qn);
  
  initial begin
    clk = 0;
    forever #5clk = ~clk;
  end
  initial begin
    rst = 1; load = 0; d = 4'b0000;#10;
    rst = 0;
    
    load = 1; d = 4'b1010;#10;
    load = 0;
    #50;
    
    
    $finish;
  end
  initial begin
    $dumpfile("piso.vcd");
    $dumpvars(1,piso_tb);
  end
  initial begin
    $monitor("Time = %0t \t CLK = %b RST = %b LOAD = %b D = %b Q = %b QN = %b",$time,clk,rst,load,d,q,qn );
  end
endmodule
  
