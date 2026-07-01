10. Implement a gray-to-binary code converter.
//Design code 
module gray_to_binary #(parameter N = 4)(
    input  wire [N-1:0] gray,
    output wire [N-1:0] binary
);

    assign binary[N-1] = gray[N-1];  

    genvar i;
    generate
        for (i = N-2; i >= 0; i = i - 1) 
          begin : loop
            assign binary[i] = binary[i+1] ^ gray[i];
        end
    endgenerate

endmodule
//Testbench code
module gray_to_binary_tb;
    reg  [3:0] gray;
    wire [3:0] binary;

    gray_to_binary #(4) dut (
        .gray(gray),
        .binary(binary)
    );

    initial begin
        $display("Time\tGray\tBinary");
        $monitor("%4t\t%b\t%b", $time, gray, binary);

        gray = 4'b0000; #10;
        gray = 4'b0001; #10;
        gray = 4'b0011; #10;
        gray = 4'b0010; #10;
        gray = 4'b0110; #10;
        gray = 4'b0111; #10;
        gray = 4'b0101; #10;
        gray = 4'b0100; #10;
        gray = 4'b1100; #10;
        gray = 4'b1101; #10;
        gray = 4'b1111; #10;
        gray = 4'b1110; #10;
        gray = 4'b1010; #10;
        gray = 4'b1011; #10;
        gray = 4'b1001; #10;
        gray = 4'b1000; #10;

        $finish;
    end
endmodule
OUTPUT
Time	Gray	Binary
   0	0000	0000
  10	0001	0001
  20	0011	0010
  30	0010	0011
  40	0110	0100
  50	0111	0101
  60	0101	0110
  70	0100	0111
  80	1100	1000
  90	1101	1001
 100	1111	1010
 110	1110	1011
 120	1010	1100
 130	1011	1101
 140	1001	1110
 150	1000	1111
