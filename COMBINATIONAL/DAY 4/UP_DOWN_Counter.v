//Design code
module up_or_down_count(
  input en,
  input ctrl_in,
  input clk,rst,
  output reg [3:0]count);
 	
  always @(posedge clk or posedge rst) begin
    if (rst) 
      count <= 4'b0000;
     
    else if(en) begin
      if(ctrl_in) 
        count <= count+1;
      else
        count <= count-1;  
    end
  end

endmodule

//testbench code
module up_or_down_count_tb();
  reg en;
  reg ctrl_in;
  reg clk,rst;
  wire [3:0]count;
  
  up_or_down_count uut(en,ctrl_in,clk,rst,count);
  
  initial begin
    clk = 0;
    forever #5clk = ~clk;
  end
  initial begin
    rst = 1; en = 0; ctrl_in = 1;#10;
    rst = 0; en = 1; ctrl_in = 1;#160;
    rst = 0; en = 1; ctrl_in = 0;#160;
    
    $finish;
  end
  initial begin
    $dumpfile("up_or_down_count.vcd");
    $dumpvars(1,up_or_down_count_tb);
  end
  initial begin
    $monitor("Time = %0t \t CLK = %b RST = %b ENABLE = %b CTRL IN = %b COUNT = %b",$time,clk,rst,en,ctrl_in,count );
  end
endmodule
  
