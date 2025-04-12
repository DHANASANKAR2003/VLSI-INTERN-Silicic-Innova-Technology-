//Design code
module ring_count(
  input clk,rst,
  output reg [3:0]count);
 	
  always @(posedge clk or posedge rst) begin
    if(rst)
      count <= 4'b1000;
    else
      count <= {count[2:0],count[3]};
  end
endmodule

//testbench code
module ring_count_tb();
  reg clk,rst;
  wire [3:0]count;
  
  ring_count uut(clk,rst,count);
  
  initial begin
    clk = 0;
    forever #5clk = ~clk;
  end
  initial begin
    rst = 1;#10;
    rst = 0;#100;
   
    
    $finish;
  end
  initial begin
    $dumpfile("ring_count.vcd");
    $dumpvars(1,ring_count_tb);
  end
  initial begin
    $monitor("Time = %0t \t CLK = %b RST = %b COUNT = %b",$time,clk,rst,count );
  end
endmodule
  
