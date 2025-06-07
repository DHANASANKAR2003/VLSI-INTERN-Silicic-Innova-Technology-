6. Implement an 8-to-3 priority encoder.
//Design code 
module priority_encoder_8to3 (
    input wire [7:0] in,
    output reg [2:0] out,
    output reg valid
);
    always @(*) begin
        valid = 1'b0;
        out = 3'b000;

        if (in[7]) begin
            out = 3'b111; 
            valid = 1'b1;
        end else if (in[6]) begin
            out = 3'b110; 
            valid = 1'b1;
        end else if (in[5]) begin
            out = 3'b101; 
            valid = 1'b1;
        end else if (in[4]) begin
            out = 3'b100; 
            valid = 1'b1;
        end else if (in[3]) begin
            out = 3'b011; 
            valid = 1'b1;
        end else if (in[2]) begin
            out = 3'b010; 
            valid = 1'b1;
        end else if (in[1]) begin
            out = 3'b001; 
            valid = 1'b1;
        end else if (in[0]) begin
            out = 3'b000; 
            valid = 1'b1;
        end
    end
endmodule
//Testbench code
module priority_encoder_8to3_tb;
  reg [7:0] in;
  wire [2:0] out;
  wire valid;
  
  priority_encoder_8to3 dut (
    .in(in),
    .out(out),
    .valid(valid)
  );

  initial begin
    $display("Time |    in    | valid | out ");
    $monitor("%4t | %b |   %b   | %b", $time, in, valid, out);

    in = 8'b00000000; #10; 
    in = 8'b00000001; #10; 
    in = 8'b00000010; #10; 
    in = 8'b00001100; #10;
    in = 8'b10000000; #10; 
    in = 8'b01010101; #10; 
    in = 8'b00100000; #10; 
    in = 8'b00010000; #10; 
    in = 8'b00000000; #10; 
    
    $finish;
  end
endmodule
OUTPUT
Time |    in    | valid | out 
   0 | 00000000 |   0   | 000
  10 | 00000001 |   1   | 000
  20 | 00000010 |   1   | 001
  30 | 00001100 |   1   | 011
  40 | 10000000 |   1   | 111
  50 | 01010101 |   1   | 110
  60 | 00100000 |   1   | 101
  70 | 00010000 |   1   | 100
  80 | 00000000 |   0   | 000
