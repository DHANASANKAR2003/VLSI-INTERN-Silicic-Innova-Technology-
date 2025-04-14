module top_module( 
    input [99:0] in,
    output [99:0] out
);
    always @(*) begin
    for (int i=0 ; i < $bits(out) ; i++)	
      out[i] = in[$bits(out)-i-1];	      
	end

endmodule
