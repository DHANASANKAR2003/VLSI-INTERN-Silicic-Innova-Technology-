//Design code
module siso(
  input d,
  input clk,rst,load,
  output reg q,
  output qn);
  
  reg [3:0] shift_reg;
  
  assign qn = ~q;	
  
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      shift_reg <= 4'b0000;
      q <= 0;
    end else begin
      shift_reg <= {shift_reg[2:0], d};
      q <= shift_reg[3];  
    end
  end

endmodule

//testbench code
module siso_tb();
  reg d;
  reg clk,rst,load;
  wire q;
  wire qn;
  
  siso uut(d,clk,rst,load,q,qn);
  
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
    load = 0;
    d = 1;#10;
    d = 0;#10;
    d = 1;#10;
    d = 0; #10;
    $finish;
  end
  initial begin
    $dumpfile("siso.vcd");
    $dumpvars(1,siso_tb);
  end
  initial begin
    $monitor("Time = %0t \t CLK = %b RST = %b LOAD = %b D = %b Q = %b QN = %b",$time,clk,rst,load,d,q,qn );
  end
endmodule
  
