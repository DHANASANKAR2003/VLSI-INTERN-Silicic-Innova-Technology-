Write RTL code for designing an 8:1 mux using a for loop. 

module mux_8x1_for ( 
    input  [7:0] in,      // 8 input lines 
    input  [2:0] sel,     // 3-bit select line 
    output reg out        // 1 output 
); 
 
integer i; 
 
always @(*) begin 
    out = 1'b0;  // default value 
    for (i = 0; i < 8; i = i + 1) begin 
        if (sel == i) 
            out = in[i]; 
    end 
end 
endmodule 
 
