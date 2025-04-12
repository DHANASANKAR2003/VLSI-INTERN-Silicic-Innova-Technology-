//Design code
module sipo(
  input d,
  input clk,rst,load,
  output reg [3:0]q,
  output qn);
  
  assign qn = ~q;	
  
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      q <= 4'b0000;
    end else begin
      q <= {q[2:0], d};
       
    end
  end

endmodule

//testbench code
module sipo_tb();
  reg d;
  reg clk,rst,load;
  wire [3:0]q;
  wire qn;
  
  sipo uut(d,clk,rst,load,q,qn);
  
  initial begin
    clk = 0;
    forever #5clk = ~clk;
  end
  initial begin
    rst = 1; load = 0; d = 0;#10;
    rst = 0;
    
    load = 1;
    d = 1;#10;
    d = 0;#10;
    d = 1;#10;
    d = 0; #10;
    load = 0;#30;
    $finish;
  end
  initial begin
    $dumpfile("sipo.vcd");
    $dumpvars(1,sipo_tb);
  end
  initial begin
    $monitor("Time = %0t \t CLK = %b RST = %b LOAD = %b D = %b Q = %b QN = %b",$time,clk,rst,load,d,q,qn );
  end
endmodule
  
