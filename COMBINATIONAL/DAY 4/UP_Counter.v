//Design code
module up_count(
  input en,
  input clk,rst,
  output reg [3:0]count);
 	
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      count <= 4'b0000;
    end 
    else if(en) begin
     count <= count+1;
       
    end
  end

endmodule

//testbench code
module up_count_tb();
  reg en;
  reg clk,rst;
  wire [3:0]count;
  
  up_count uut(en,clk,rst,count);
  
  initial begin
    clk = 0;
    forever #5clk = ~clk;
  end
  initial begin
    rst = 1; en = 0; #10;
    rst = 0; en = 1; #150; 
    en = 0; #20;           
    en = 1; #30;          
    rst = 1; #10;               
    rst = 0; #20;
    $finish;
  end
  initial begin
    $dumpfile("up_count.vcd");
    $dumpvars(1,up_count_tb);
  end
  initial begin
    $monitor("Time = %0t \t CLK = %b RST = %b ENABLE = %b COUNT = %b",$time,clk,rst,en,count );
  end
endmodule
  
