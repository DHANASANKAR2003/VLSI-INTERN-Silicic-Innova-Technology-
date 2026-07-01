7. Implement a 2-to-4 decoder.
//Design code 
module decoder_2to4 (
    input wire [1:0] in,
    input wire en,         
    output reg [3:0] out
);
    always @(*) 
      begin
        if (en) 
          begin
            case (in)
                2'b00: out = 4'b0001;
                2'b01: out = 4'b0010;
                2'b10: out = 4'b0100;
                2'b11: out = 4'b1000;
                default: out = 4'b0000;
            endcase
          end 
        else
          out = 4'b0000;
      end
endmodule
//Testbench code
module decoder_2to4_tb;
    reg [1:0] in;
    reg en;
    wire [3:0] out;

    decoder_2to4 uut (
        .in(in),
        .en(en),
        .out(out)
    );

    initial begin
        $display("Time\tEN\tIN\tOUT");
        $monitor("%0t\t%b\t%b\t%b", $time, en, in, out);

        en = 0; 
        in = 2'b00; #10;
        in = 2'b01; #10;
        in = 2'b10; #10;
        in = 2'b11; #10;

        en = 1; 
        in = 2'b00; #10;
        in = 2'b01; #10;
        in = 2'b10; #10;
        in = 2'b11; #10;

        $finish;
    end
endmodule
OUTPUT
Time	EN	IN	 OUT
0	    0	  00	0000
10	  0	  01	0000
20	  0	  10	0000
30	  0	  11	0000
40	  1	  00	0001
50	  1	  01	0010
60	  1	  10	0100
70	  1	  11	1000
