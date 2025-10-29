//DESIGN
module always_flipflop(
  input logic clk,rst,
  input logic [7:0]d,
  output logic [7:0]q);
  
  always_ff @(posedge clk or posedge rst) begin
    if(rst)
      q <= 8'b0;
    else
      q <= d;
  end
endmodule
  

//TESTBENCH
module always_flipflop_tb;
  logic clk,rst;
  logic [7:0]d;
  logic [7:0]q;
  
  always_flipflop dut(
    .clk(clk),
    .rst(rst),
    .d(d),
    .q(q)
  );
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    $monitor("time = %0t\t clk = %0d\t rst = %0d\t d = %0d\t q = %0d",$time,clk,rst,d,q);
    rst = 1'b1;
    #10;
    d = 8'b0;
    #10;
    rst = 1'b0;
    #10;
    d = 8'd10;
    #10;
    d = 8'd20;
    #10;
    d = 8'd10;
    #10;
    d = 8'd20;
    #10;
    d = 8'd10;
    #10;
    d = 8'd20;
    #30;
    rst = 1'b1;
    d = 8'd20;
    #10;
    d = 8'd10;
    #10;
    d = 8'd20;
    #10;
    $finish;
  end
  initial begin
    $dumpfile("Design.vcd");
    $dumpvars();
  end
endmodule


OUTPUT

time = 0	 clk = 0	 rst = 1	 d = x	 q = x
time = 5	 clk = 1	 rst = 1	 d = x	 q = x
time = 10	 clk = 0	 rst = 1	 d = 0	 q = 0
time = 15	 clk = 1	 rst = 1	 d = 0	 q = 0
time = 20	 clk = 0	 rst = 0	 d = 0	 q = 0
time = 25	 clk = 1	 rst = 0	 d = 0	 q = 0
time = 30	 clk = 0	 rst = 0	 d = 10	 q = 0
time = 35	 clk = 1	 rst = 0	 d = 10	 q = 0
time = 40	 clk = 0	 rst = 0	 d = 20	 q = 0
time = 45	 clk = 1	 rst = 0	 d = 20	 q = 0
time = 50	 clk = 0	 rst = 0	 d = 10	 q = 0
time = 55	 clk = 1	 rst = 0	 d = 10	 q = 0
time = 60	 clk = 0	 rst = 0	 d = 20	 q = 0
time = 65	 clk = 1	 rst = 0	 d = 20	 q = 0
time = 70	 clk = 0	 rst = 0	 d = 10	 q = 0
time = 75	 clk = 1	 rst = 0	 d = 10	 q = 0
time = 80	 clk = 0	 rst = 0	 d = 20	 q = 0
time = 85	 clk = 1	 rst = 0	 d = 20	 q = 0
time = 90	 clk = 0	 rst = 0	 d = 20	 q = 0
time = 95	 clk = 1	 rst = 0	 d = 20	 q = 0
time = 100	 clk = 0	 rst = 0	 d = 20	 q = 0
time = 105	 clk = 1	 rst = 0	 d = 20	 q = 0
time = 110	 clk = 0	 rst = 1	 d = 20	 q = 20
time = 115	 clk = 1	 rst = 1	 d = 20	 q = 20
time = 120	 clk = 0	 rst = 1	 d = 10	 q = 10
time = 125	 clk = 1	 rst = 1	 d = 10	 q = 10
time = 130	 clk = 0	 rst = 1	 d = 20	 q = 20
time = 135	 clk = 1	 rst = 1	 d = 20	 q = 20
