//DESIGN

module always_latch_design(
  input logic en,
  input logic [7:0]d,
  output logic [7:0]q);
  
  always_latch begin
    if(en)
      q = d;
  end
endmodule

//TESTBENCH

module always_latch_tb;
  logic en;
  logic [7:0]d;
  logic [7:0]q;
  
  always_latch_design dut(
    .en(en),
    .d(d),
    .q(q)
  );

  initial begin
    $monitor("time = %0t\t en = %0d\t d = %0d\t q = %0d",$time,en,d,q);
    en = 1'b0;
    #10;
    d = 8'b0;
    #10;
    en = 1'b1;
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
    en = 1'b0;
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
    $dumpvars;
  end
endmodule

//OUTPUT

time = 0	 en = 0	 d = x	 q = x
time = 10	 en = 0	 d = 0	 q = x
time = 20	 en = 1	 d = 0	 q = 0
time = 30	 en = 1	 d = 10	 q = 10
time = 40	 en = 1	 d = 20	 q = 20
time = 50	 en = 1	 d = 10	 q = 10
time = 60	 en = 1	 d = 20	 q = 20
time = 70	 en = 1	 d = 10	 q = 10
time = 80	 en = 1	 d = 20	 q = 20
time = 110	 en = 0	 d = 20	 q = 20
time = 120	 en = 0	 d = 10	 q = 20
time = 130	 en = 0	 d = 20	 q = 20
  
      
