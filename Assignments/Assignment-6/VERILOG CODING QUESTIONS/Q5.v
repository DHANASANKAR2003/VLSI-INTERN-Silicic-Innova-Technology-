5. Design a 4-to-2 priority encoder with a valid bit output.
//Design code 
module priority_encoder_4to2 (
    input wire [3:0] in,
    output reg [1:0] out,
    output reg valid
);

    always @(*) begin
        if (in[3]) begin
            out = 2'b11;
            valid = 1'b1;
        end else if (in[2]) begin
            out = 2'b10;
            valid = 1'b1;
        end else if (in[1]) begin
            out = 2'b01;
            valid = 1'b1;
        end else if (in[0]) begin
            out = 2'b00;
            valid = 1'b1;
        end else begin
            out = 2'b00;  
            valid = 1'b0;
        end
    end
endmodule

//Testbench code
module priority_encoder_4to2_tb;
    reg [3:0] in;
    wire [1:0] out;
    wire valid;

    priority_encoder_4to2 dut (
        .in(in),
        .out(out),
        .valid(valid)
    );

    initial begin
        $display("Time\tInput\tOutput\tValid");
        
        in = 4'b0000; #10;
        $display("%0t\t%b\t%b\t%b", $time, in, out, valid);
        
        in = 4'b0001; #10;
        $display("%0t\t%b\t%b\t%b", $time, in, out, valid);
        
        in = 4'b0010; #10;
        $display("%0t\t%b\t%b\t%b", $time, in, out, valid);
        
        in = 4'b0100; #10;
        $display("%0t\t%b\t%b\t%b", $time, in, out, valid);
        
        in = 4'b1000; #10;
        $display("%0t\t%b\t%b\t%b", $time, in, out, valid);
        
        in = 4'b1010; #10; 
        $display("%0t\t%b\t%b\t%b", $time, in, out, valid);

        in = 4'b0110; #10;  
        $display("%0t\t%b\t%b\t%b", $time, in, out, valid);

        $finish;
    end
endmodule
OUTPUT
Time	Input	Output	Valid
10	  0000	  00	    0
20	  0001	  00	    1
30	  0010	  01	    1
40	  0100	  10	    1
50 	  1000	  11	    1
60	  1010	  11	    1
70	  0110	  10	    1
