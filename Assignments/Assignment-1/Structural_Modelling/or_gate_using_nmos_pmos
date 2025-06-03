//Design code 
module or_gate_using_cmos (
    input A, B,
    output Y
);

    wire not_a, not_b;
    wire nand_out;

    supply1 VDD;
    supply0 GND;

    nmos (not_a, GND, A);
    pmos (not_a, VDD, A);

    nmos (not_b, GND, B);
    pmos (not_b, VDD, B);

    wire n_n1;
    nmos (n_n1, GND, not_a);   
    nmos (nand_out, n_n1, not_b);

    pmos (nand_out, VDD, not_a);  
    pmos (nand_out, VDD, not_b);

    nmos (Y, GND, nand_out);
    pmos (Y, VDD, nand_out);

endmodule

//Test Bench code
`timescale 1ns/1ps

module or_gate_using_cmos_tb;

    reg A, B;
    wire Y;
    or_gate_using_cmos uut (
        .A(A),
        .B(B),
        .Y(Y)
    );

    initial begin
        $display("A B | Y");
        $display("--------");
        A = 0; B = 0; #10;
        $display("%b %b | %b", A, B, Y);

        A = 0; B = 1; #10;
        $display("%b %b | %b", A, B, Y);

        A = 1; B = 0; #10;
        $display("%b %b | %b", A, B, Y);

        A = 1; B = 1; #10;
        $display("%b %b | %b", A, B, Y);

        $finish;
    end

endmodule

//Output
A B | Y
--------
0 0 | 1
0 1 | 0
1 0 | 0
1 1 | 0
testbench.sv:29: $finish called at 40000 (1ps)
