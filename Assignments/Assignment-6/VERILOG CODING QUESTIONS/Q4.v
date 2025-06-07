4. Implement an 8:1 multiplexer using two 4:1 MUXs.
//Design code 
module mux4to1 (
    input wire [3:0] data_in,
    input wire [1:0] sel,
    output reg out
);
    always @(*) begin
        case (sel)
            2'b00: out = data_in[0];
            2'b01: out = data_in[1];
            2'b10: out = data_in[2];
            2'b11: out = data_in[3];
            default: out = 1'b0;
        endcase
    end
endmodule

module mux2to1 (
    input wire in0,
    input wire in1,
    input wire sel,
    output wire out
);
    assign out = sel ? in1 : in0;
endmodule


module mux8to1 (
    input wire [7:0] data_in,
    input wire [2:0] sel,
    output wire out
);
    wire out_lower, out_upper;

    mux4to1 lower_mux (
        .data_in(data_in[3:0]),
        .sel(sel[1:0]),
        .out(out_lower)
    );

    mux4to1 upper_mux (
        .data_in(data_in[7:4]),
        .sel(sel[1:0]),
        .out(out_upper)
    );

    mux2to1 final_mux (
        .in0(out_lower),
        .in1(out_upper),
        .sel(sel[2]),
        .out(out)
    );
endmodule
//Testbench code
module mux8to1_tb;
    reg [7:0] data_in;
    reg [2:0] sel;
    wire out;

    mux8to1 dut (
        .data_in(data_in),
        .sel(sel),
        .out(out)
    );

    initial begin
        $display("Time\tSel\tData_in\tOutput");
        data_in = 8'b10101010; 

        for (integer i = 0; i < 8; i = i + 1) begin
            sel = i;
            #10;
            $display("%0t\t%b\t%b\t%b", $time, sel, data_in, out);
        end

        $finish;
    end
endmodule
OUTPUT
Time	Sel	 Data_in	 Output
10	  000	 10101010	   0
20	  001	 10101010	   1
30	  010	 10101010	   0
40	  011	 10101010	   1
50	  100	 10101010  	 0
60	  101	 10101010	   1
70	  110	 10101010	   0
80	  111	 10101010	   1
