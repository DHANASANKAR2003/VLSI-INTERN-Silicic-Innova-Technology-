`timescale 1ns/1ps
module divisible_by_5_fsm (
    input wire clk,
    input wire rst,
    input wire serial_in,         // Serial binary input
    output reg out         // Output is 1 when divisible by 5
);

  // State encoding
  parameter S0 = 3'd0;  // remainder 0
  parameter S1 = 3'd1;  // remainder 1
  parameter S2 = 3'd2;  // remainder 2
  parameter S3 = 3'd3;  // remainder 3
  parameter S4 = 3'd4;  // remainder 4

  reg [2:0] current_state, next_state;

  // Next state logic
  always @(*) begin
    case (current_state)
      S0: next_state = serial_in ? S1 : S0;
      S1: next_state = serial_in ? S3 : S2;
      S2: next_state = serial_in ? S0 : S4;
      S3: next_state = serial_in ? S2 : S1;
      S4: next_state = serial_in ? S4 : S3;
      default: next_state = S0;
    endcase
  end


  always @(posedge clk or posedge rst) begin
    if (rst)
      current_state <= S0;
    else
      current_state <= next_state;
  end

  always @(*) begin
        if (rst)
            out = 0;
        else
            out = (next_state == S0) ? 1 : 0;
    end

endmodule
`timescale 1ns/1ps

module mod5_serial_detector_tb;
    reg clk, rst, serial_in;
    wire out;

    // Instantiate your FSM module (update the module name if different)
    divisible_by_5_fsm uut (
        .clk(clk),
        .rst(rst),
        .serial_in(serial_in),
        .out(out)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // VCD dump for waveform viewing
        $dumpfile("mod5.vcd");
        $dumpvars(0, mod5_serial_detector_tb);

        $display("Time\tClk\tRst\tIn\tOut");
        $monitor("%g\t%b\t%b\t%b\t%b", $time, clk, rst, serial_in, out);

        // Apply reset
        
        rst = 1; serial_in = 0; #10;
        rst = 0;

        // Input sequence example (similar to your given pattern)
        serial_in = 1; @(posedge clk);
        serial_in = 0; @(posedge clk);
        serial_in = 1; @(posedge clk);
        serial_in = 0; @(posedge clk);

        serial_in = 1; @(posedge clk);
        serial_in = 0; @(posedge clk);
        serial_in = 0; @(posedge clk);
        serial_in = 1; @(posedge clk);

        // Apply reset again in between
        rst = 1; @(posedge clk);
        rst = 0;

        serial_in = 1; @(posedge clk);
        serial_in = 1; @(posedge clk);
        serial_in = 1; @(posedge clk);
        serial_in = 1; @(posedge clk);

        serial_in = 0; @(posedge clk);
        serial_in = 0; @(posedge clk);
        serial_in = 0; @(posedge clk);
        serial_in = 0; @(posedge clk);

        #20;
        $finish;
    end

endmodule
VCD info: dumpfile mod5.vcd opened for output.
Time	Clk	Rst	In	Out
0	0	1	0	0
5	1	1	0	0
10	0	0	1	0
15	1	0	0	0
20	0	0	0	0
25	1	0	1	1
30	0	0	1	1
35	1	0	0	1
40	0	0	0	1
45	1	0	1	0
50	0	0	1	0
55	1	0	0	0
60	0	0	0	0
65	1	0	0	0
70	0	0	0	0
75	1	0	1	0
80	0	0	1	0
85	1	1	1	0
90	0	1	1	0
95	1	0	1	0
100	0	0	1	0
105	1	0	1	0
110	0	0	1	0
115	1	0	1	1
120	0	0	1	1
125	1	0	1	0
130	0	0	1	0
135	1	0	0	0
140	0	0	0	0
145	1	0	0	0
150	0	0	0	0
155	1	0	0	0
160	0	0	0	0
165	1	0	0	0
170	0	0	0	0
175	1	0	0	0
180	0	0	0	0
185	1	0	0	0
190	0	0	0	0
testbench.sv:58: $finish called at 195000 (1ps)
195	1	0	0	0
Done
  
