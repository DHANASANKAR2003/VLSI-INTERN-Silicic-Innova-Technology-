8. Implement a 3-to-8 decoder.
//Design code 
module decoder_3to8 (
    input wire [2:0] in,
    input wire en,
    output reg [7:0] out
);
    always @(*) begin
        if (en)
            out = 1 << in;  
        else
            out = 8'b00000000;  
    end
endmodule

//Testbench code
module decoder_3to8_tb;
    reg [2:0] in;
    reg en;
    wire [7:0] out;

    decoder_3to8 uut (
        .in(in),
        .en(en),
        .out(out)
    );

    initial begin
        $display("Time\tEN\tIN\tOUT");
        $monitor("%0t\t%b\t%03b\t%b", $time, en, in, out);

        en = 0; 
        in = 3'b000; #10;
        in = 3'b101; #10;
      
        en = 1;
        in = 3'b000; #10;
        in = 3'b001; #10;
        in = 3'b010; #10;
        in = 3'b011; #10;
        in = 3'b100; #10;
        in = 3'b101; #10;
        in = 3'b110; #10;
        in = 3'b111; #10;

        $finish;
    end
endmodule

OUTPUT
Time	EN  IN    OUT
0	    0	  000	00000000
10	  0	  101	00000000
20	  1	  000	00000001
30	  1	  001	00000010
40	  1	  010	00000100
50	  1	  011	00001000
60	  1	  100	00010000
70	  1	  101	00100000
80	  1	  110	01000000
90	  1	  111	10000000
