3. Design a 4:1 multiplexer using case statements.
//Design Code 
module mux_4_1(
  input [3:0]data_in,
  input [1:0]sel,
  output reg out
);
  always@(*)
    begin
      case(sel)
        2'b00 : out = data_in[0];
        2'b01 : out = data_in[1];
        2'b10 : out = data_in[2];
        2'b11 : out = data_in[3];
        default: out = 1'b0;
      endcase
    end
endmodule 

//tetbench code
module mux4to1_case_tb;
    reg [3:0] data_in;
    reg [1:0] sel;
    wire out;

    mux_4_1 dut (
        .data_in(data_in),
        .sel(sel),
        .out(out)
    );

    initial begin
        $display("Time\tSel\tData\tOut");
        
        data_in = 4'b1010;

        sel = 2'b00; #10;
        $display("%0t\t%b\t%b\t%b", $time, sel, data_in, out);

        sel = 2'b01; #10;
        $display("%0t\t%b\t%b\t%b", $time, sel, data_in, out);

        sel = 2'b10; #10;
        $display("%0t\t%b\t%b\t%b", $time, sel, data_in, out);

        sel = 2'b11; #10;
        $display("%0t\t%b\t%b\t%b", $time, sel, data_in, out);

        data_in = 4'b1100;

        sel = 2'b00; #10;
        $display("%0t\t%b\t%b\t%b", $time, sel, data_in, out);

        sel = 2'b01; #10;
        $display("%0t\t%b\t%b\t%b", $time, sel, data_in, out);

        sel = 2'b10; #10;
        $display("%0t\t%b\t%b\t%b", $time, sel, data_in, out);

        sel = 2'b11; #10;
        $display("%0t\t%b\t%b\t%b", $time, sel, data_in, out);

        $finish;
    end
endmodule

OUTPUT
Time	Sel	Data	Out
10	  00	1010	0
20	  01	1010	1
30	  10	1010	0
40	  11	1010	1
50	  00	1100	0
60	  01	1100	0
70	  10	1100	1
80	  11	1100	1
