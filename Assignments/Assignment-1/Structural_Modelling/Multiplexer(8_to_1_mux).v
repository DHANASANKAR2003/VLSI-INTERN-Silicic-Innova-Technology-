4. Multiplexer (8 to 1 mux)
a. Implement 8 to 1 mux using 4 to 1 mux
//Design Code 
module mux2to1 (
    input A, B,
    input sel,
    output Y
);
    assign Y = sel ? B : A;
endmodule
module mux4to1 (
    input [3:0] I,
    input [1:0] sel,
    output Y
);
    assign Y = (sel == 2'b00) ? I[0] :
               (sel == 2'b01) ? I[1] :
               (sel == 2'b10) ? I[2] : I[3];
endmodule
module mux8to1_using_4to1 (
    input [7:0] I,
    input [2:0] sel,
    output Y
);
    wire Y0, Y1;
    mux4to1 mux_low (
        .I(I[3:0]),
        .sel(sel[1:0]),
        .Y(Y0)
    );
    mux4to1 mux_high (
        .I(I[7:4]),
        .sel(sel[1:0]),
        .Y(Y1)
    );
    mux2to1 mux_final (
        .A(Y0),
        .B(Y1),
        .sel(sel[2]),
        .Y(Y)
    );
endmodule

b. Write testbench to check design behaviour
// Test Bench Code
`timescale 1ns/1ps
module mux8to1_tb;
    reg [7:0] I;
    reg [2:0] sel;
    wire Y;
    reg expected;
    integer i;
    mux8to1_using_4to1 uut (
        .I(I),
        .sel(sel),
        .Y(Y)
    );

    initial begin
        $display("=== TEST CASE 1: Valid Pattern, Should PASS ===");
        I = 8'b10101010; 
        for (i = 0; i < 8; i = i + 1) begin
            sel = i[2:0];
            expected = I[i];
            #10;
            if (Y === expected)
                $display("PASS: sel=%b, Y=%b, expected=%b", sel, Y, expected);
            else
                $display("FAIL: sel=%b, Y=%b, expected=%b", sel, Y, expected);
        end
        $display("\n=== TEST CASE 2: Intentionally Faulty Expected Values, Should FAIL ===");
        I = 8'b11001100; 
        for (i = 0; i < 8; i = i + 1)
          begin
            sel = i[2:0];
            expected = ~I[i];  
            #10;
            if (Y === expected)
                $display("PASS (unexpected): sel=%b, Y=%b, expected=%b", sel, Y, expected);
            else
                $display("FAIL (as expected): sel=%b, Y=%b, expected=%b", sel, Y, expected);
        end
        $finish;
    end

endmodule

//Output
=== TEST CASE 1: Valid Pattern, Should PASS ===
PASS: sel=000, Y=0, expected=0
PASS: sel=001, Y=1, expected=1
PASS: sel=010, Y=0, expected=0
PASS: sel=011, Y=1, expected=1
PASS: sel=100, Y=0, expected=0
PASS: sel=101, Y=1, expected=1
PASS: sel=110, Y=0, expected=0
PASS: sel=111, Y=1, expected=1

=== TEST CASE 2: Intentionally Faulty Expected Values, Should FAIL ===
FAIL (as expected): sel=000, Y=0, expected=1
FAIL (as expected): sel=001, Y=0, expected=1
FAIL (as expected): sel=010, Y=1, expected=0
FAIL (as expected): sel=011, Y=1, expected=0
FAIL (as expected): sel=100, Y=0, expected=1
FAIL (as expected): sel=101, Y=0, expected=1
FAIL (as expected): sel=110, Y=1, expected=0
FAIL (as expected): sel=111, Y=1, expected=0
testbench.sv:38: $finish called at 160000 (1ps)
