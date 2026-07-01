//Design Code 
module and_gate_using_cmos (
    input A, B,
    output Y
);

    wire nand_out;
    wire w_n1;
  
    supply1 VDD;
    supply0 GND;
  
    nmos (w_n1, GND, A);  
    nmos (nand_out, w_n1, B); 
    wire w_p1, w_p2;
    pmos (nand_out, VDD, A); 
    pmos (nand_out, VDD, B);
    wire w_inv;

    nmos (Y, GND, nand_out);  
    pmos (Y, VDD, nand_out); 

endmodule

//Test Bench code
`timescale 1ns/1ps

module and_gate_using_cmos_tb;

    reg A, B;
    wire Y;
    and_gate_using_cmos uut (
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
0 0 | 0
0 1 | 0
1 0 | 0
1 1 | 1
testbench.sv:32: $finish called at 40000 (1ps)
