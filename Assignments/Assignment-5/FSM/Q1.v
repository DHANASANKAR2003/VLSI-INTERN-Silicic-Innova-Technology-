//Design code 
module fsm_000_or_111(
  input clk,
  input rst,
  input x,
  output reg y
);
  
  parameter S0 = 3'b000;
  parameter S1 = 3'b001;
  parameter S2 = 3'b010;
  parameter S3 = 3'b011;
  parameter S4 = 3'b100;
  parameter S5 = 3'b101;
  parameter S6 = 3'b110;
  
  reg [2:0] CS,NS;	
  
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        CS <= S0;
      else
        CS <= NS;
    end
  
  always@(*)
    begin
      case(CS)
        S0 : NS = (x == 1) ? S1 : S4;
        S1 : NS = (x == 1) ? S2 : S4;
        S2 : NS = (x == 1) ? S3 : S4;
        S3 : NS = (x == 1) ? S3 : S4;
        S4 : NS = (x == 1) ? S1 : S5;
        S5 : NS = (x == 1) ? S1 : S6;
        S6 : NS = (x == 1) ? S1 : S6;
        default : NS = S0;
      endcase
    end
  always@(*)
    begin 
      case(CS)
        S3 : y = 1;
        S6 : y = 1;
        default : y = 0;
      endcase
    end 
  
endmodule 

// Code testbench 
module fsm_000_or_111_tb;
  reg clk;
  reg rst;
  reg x;
  wire y;
  
  fsm_000_or_111 dut(
    .clk(clk),
    .rst(rst),
    .x(x),
    .y(y));
  
  initial 
    clk = 0;
    always #5clk = ~clk;
  
  initial begin 
    rst = 1;
    x = 0;#10;
    
    rst = 0;
    
    repeat(1) @(posedge clk); 
    x = 1;
    repeat(2) @(posedge clk); 
    x = 1;
    repeat(2) @(posedge clk); 
    x = 1;
    repeat(1) @(posedge clk); 
    x = 0;
    repeat(1) @(posedge clk); 
    x = 0;
    repeat(3) @(posedge clk); 
    x = 1;
    repeat(1) @(posedge clk); 
    x = 1;
    repeat(2) @(posedge clk); 
    x = 0;
    repeat(1) @(posedge clk); 
    x = 1;
    repeat(4) @(posedge clk); 
    x = 1;
    repeat(1) @(posedge clk); 
    x = 1;
    repeat(5) @(posedge clk); 
    x = 0;
    
      #30; $finish;
  end
  
  initial begin 
      $monitor("|Time %0t\t | CLOCK %b\t | RESET %b\t | INPUT = %b\t | OUTPUT = %b|",$time,clk,rst,x,y);
  end
  
  initial begin
    $dumpfile("FSM.vcd");              
    $dumpvars(1, fsm_000_or_111_tb);   
  end
endmodule

VCD info: dumpfile FSM.vcd opened for output.
|Time 0	 | CLOCK 0	 | RESET 1	 | INPUT = 0	 | OUTPUT = 0|
|Time 5	 | CLOCK 1	 | RESET 1	 | INPUT = 0	 | OUTPUT = 0|
|Time 10	 | CLOCK 0	 | RESET 0	 | INPUT = 0	 | OUTPUT = 0|
|Time 15	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 0|
|Time 20	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 0|
|Time 25	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 0|
|Time 30	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 0|
|Time 35	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 0|
|Time 40	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 0|
|Time 45	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 50	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 55	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 60	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 65	 | CLOCK 1	 | RESET 0	 | INPUT = 0	 | OUTPUT = 1|
|Time 70	 | CLOCK 0	 | RESET 0	 | INPUT = 0	 | OUTPUT = 1|
|Time 75	 | CLOCK 1	 | RESET 0	 | INPUT = 0	 | OUTPUT = 0|
|Time 80	 | CLOCK 0	 | RESET 0	 | INPUT = 0	 | OUTPUT = 0|
|Time 85	 | CLOCK 1	 | RESET 0	 | INPUT = 0	 | OUTPUT = 0|
|Time 90	 | CLOCK 0	 | RESET 0	 | INPUT = 0	 | OUTPUT = 0|
|Time 95	 | CLOCK 1	 | RESET 0	 | INPUT = 0	 | OUTPUT = 1|
|Time 100	 | CLOCK 0	 | RESET 0	 | INPUT = 0	 | OUTPUT = 1|
|Time 105	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 110	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 115	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 0|
|Time 120	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 0|
|Time 125	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 0|
|Time 130	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 0|
|Time 135	 | CLOCK 1	 | RESET 0	 | INPUT = 0	 | OUTPUT = 1|
|Time 140	 | CLOCK 0	 | RESET 0	 | INPUT = 0	 | OUTPUT = 1|
|Time 145	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 0|
|Time 150	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 0|
|Time 155	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 0|
|Time 160	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 0|
|Time 165	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 0|
|Time 170	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 0|
|Time 175	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 180	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 185	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 190	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 195	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 200	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 205	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 210	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 215	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 220	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 225	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 230	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 235	 | CLOCK 1	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 240	 | CLOCK 0	 | RESET 0	 | INPUT = 1	 | OUTPUT = 1|
|Time 245	 | CLOCK 1	 | RESET 0	 | INPUT = 0	 | OUTPUT = 1|
|Time 250	 | CLOCK 0	 | RESET 0	 | INPUT = 0	 | OUTPUT = 1|
|Time 255	 | CLOCK 1	 | RESET 0	 | INPUT = 0	 | OUTPUT = 0|
|Time 260	 | CLOCK 0	 | RESET 0	 | INPUT = 0	 | OUTPUT = 0|
|Time 265	 | CLOCK 1	 | RESET 0	 | INPUT = 0	 | OUTPUT = 0|
|Time 270	 | CLOCK 0	 | RESET 0	 | INPUT = 0	 | OUTPUT = 0|
testbench.sv:49: $finish called at 275 (1s)
|Time 275	 | CLOCK 1	 | RESET 0	 | INPUT = 0	 | OUTPUT = 1|
Done
