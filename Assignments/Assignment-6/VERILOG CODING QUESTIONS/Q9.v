9. Implement a binary-to-gray code converter.
//Design code 
module binary_to_gray (
    input  wire [3:0] binary_in,  
    output wire [3:0] gray_out     
);
    assign gray_out[3] = binary_in[3];        
    assign gray_out[2] = binary_in[3] ^ binary_in[2];
    assign gray_out[1] = binary_in[2] ^ binary_in[1];
    assign gray_out[0] = binary_in[1] ^ binary_in[0];

endmodule

//Testbench code
module binary_to_gray_tb;
    reg  [3:0] binary_in;
    wire [3:0] gray_out;

    binary_to_gray dut (
        .binary_in(binary_in),
        .gray_out(gray_out)
    );

    initial begin
        $display("Time | Binary | Gray");
      $monitor("%4t | %b    | %b", $time, binary_in, gray_out);

        binary_in = 4'b0000; #10;
        binary_in = 4'b0001; #10;
        binary_in = 4'b0010; #10;
        binary_in = 4'b0011; #10;
        binary_in = 4'b0100; #10;
        binary_in = 4'b0101; #10;
        binary_in = 4'b0110; #10;
        binary_in = 4'b0111; #10;
        binary_in = 4'b1000; #10;
        binary_in = 4'b1001; #10;
        binary_in = 4'b1010; #10;
        binary_in = 4'b1011; #10;
        binary_in = 4'b1100; #10;
        binary_in = 4'b1101; #10;
        binary_in = 4'b1110; #10;
        binary_in = 4'b1111; #10;

        $finish;
    end
endmodule
OUTPUT
Time | Binary  | Gray
   0 | 0000    | 0000
  10 | 0001    | 0001
  20 | 0010    | 0011
  30 | 0011    | 0010
  40 | 0100    | 0110
  50 | 0101    | 0111
  60 | 0110    | 0101
  70 | 0111    | 0100
  80 | 1000    | 1100
  90 | 1001    | 1101
 100 | 1010    | 1111
 110 | 1011    | 1110
 120 | 1100    | 1010
 130 | 1101    | 1011
 140 | 1110    | 1001
 150 | 1111    | 1000
