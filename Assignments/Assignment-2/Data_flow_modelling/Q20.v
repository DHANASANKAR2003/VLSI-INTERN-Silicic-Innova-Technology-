20. Implement 4x1 Mux using continuous assignments, i.e. Data flow model. a. Assign Y = S1 ? (S0 ? i3 : i2) : (S0 ? i1 : i0); i. Do not code assign inside always 

 

//Design code 

module mux4x1 ( 

    input wire i0, i1, i2, i3, 

    input wire S0, S1, 

    output wire Y 

); 

// Dataflow model using conditional operator (?:) 

assign Y = S1 ? (S0 ? i3 : i2) : (S0 ? i1 : i0); 

endmodule 

//Testbench code 

module tb_mux4x1; 

  

    reg i0, i1, i2, i3; 

    reg S0, S1; 

    wire Y; 

  

    mux4x1 uut ( 

        .i0(i0), .i1(i1), .i2(i2), .i3(i3), 

        .S0(S0), .S1(S1), 

        .Y(Y) 

    ); 

    initial begin	 

        i0 = 0; i1 = 1; i2 = 0; i3 = 1; 

        $display("S1 S0 | Y"); 

        for (integer i = 0; i < 4; i = i + 1) begin 

            {S1, S0} = i; 

            #1; 

            $display(" %b  %b | %b", S1, S0, Y); 

        end 

        $finish; 

    end 

endmodule 

 

OUTPUT: 

S1 S0 | Y 
 0 0 | 0 
 0 1 | 1 
 1 0 | 0 
 1 1 | 1 
testbench.sv:22: $finish called at 4 (1s) 

 
