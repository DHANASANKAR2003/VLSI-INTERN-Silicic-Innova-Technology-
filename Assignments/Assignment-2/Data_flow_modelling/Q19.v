19. Implementing various gates using multiplexer a. Implement AND, OR, NAND, NOR, XOR, XNOR using multiplexer 

// Code your design here  

module gates_using_mux( input A, B,  

                                            output AND_out, OR_out, NAND_out, NOR_out, XOR_out, XNOR_out  

                                            ); 

// AND gate using MUX: Y = A & B  

assign AND_out = (A) ? B : 0; 

// OR gate using MUX: Y = A | B  

assign OR_out = (A) ? 1 : B; 

// NAND gate using MUX: Y = ~(A & B)  

assign NAND_out = (A) ? ~B : 1; 

// NOR gate using MUX: Y = ~(A | B)  

assign NOR_out = (A) ? 0 : ~B; 

// XOR gate using MUX: Y = A ^ B  

assign XOR_out = (A) ? ~B : B; 

// XNOR gate using MUX: Y = ~(A ^ B)  

assign XNOR_out = (A) ? B : ~B; 

endmodule 

 

//Testbench code 

module tb_gates_using_mux; 

reg A, B; 
wire AND_out, OR_out, NAND_out, NOR_out, XOR_out, XNOR_out; 
gates_using_mux uut ( 
    .A(A), .B(B), 
    .AND_out(AND_out), 
    .OR_out(OR_out), 
    .NAND_out(NAND_out), 
    .NOR_out(NOR_out), 
    .XOR_out(XOR_out), 
    .XNOR_out(XNOR_out) 
); 
 
initial begin 
    $display("A B | AND OR NAND NOR XOR XNOR"); 
    for (integer i = 0; i < 4; i = i + 1) begin 
        {A, B} = i; 
        #1; 
        $display("%b %b |  %b   %b   %b    %b    %b    %b",  
                 A, B, AND_out, OR_out, NAND_out, NOR_out, XOR_out, XNOR_out); 
    end 
    $finish; 
end 

endmodule 

 

OUTPUT: 

A B | AND OR NAND NOR XOR XNOR 
0 0 | 0    0   1   1   0.  1 
0 1 | 0    1   1   0   1   0 
1 0 | 0    1   1.  0   1   0 
1 1 | 1    1.  0.  0   0   1 
testbench.sv:26: $finish called at 4 (1s) 
