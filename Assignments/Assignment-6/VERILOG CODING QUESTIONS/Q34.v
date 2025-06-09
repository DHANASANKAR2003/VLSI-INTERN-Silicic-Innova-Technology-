34. Implement a 4-bit divider using restoring division.
//Design Code
module restoring_divider_4bit (
    input      [3:0] dividend,
    input      [3:0] divisor,
    output reg [3:0] quotient,
    output reg [3:0] remainder
);

  integer i;
  reg [4:0] A;  
  reg [3:0] Q;
  reg [3:0] M;

  always @(*) begin
    A = 5'd0;
    Q = dividend;
    M = divisor;

    for (i = 0; i < 4; i = i + 1) begin
      A = {A[3:0], Q[3]}; 
      Q = {Q[2:0], 1'b0};
      A = A - M;
      if (A[4] == 1) begin  
        Q[0] = 1'b0;
        A = A + M;  
      end else begin
        Q[0] = 1'b1;
      end
    end

    quotient = Q;
    remainder = A[3:0];
  end

endmodule
//Testbench code
module tb_restoring_divider_4bit;

  reg  [3:0] dividend, divisor;
  wire [3:0] quotient, remainder;

  restoring_divider_4bit uut (
    .dividend(dividend),
    .divisor(divisor),
    .quotient(quotient),
    .remainder(remainder)
  );

  initial begin
    $display("Dividend | Divisor | Quotient | Remainder");
    
    dividend = 4'd13; divisor = 4'd3; #10;
    $display("%d\t   | %d\t   | %d\t      | %d", dividend, divisor, quotient, remainder);

    dividend = 4'd9; divisor = 4'd2; #10;
    $display("%d\t   | %d\t   | %d\t      | %d", dividend, divisor, quotient, remainder);

    dividend = 4'd7; divisor = 4'd1; #10;
    $display("%d\t   | %d\t   | %d\t      | %d", dividend, divisor, quotient, remainder);

    dividend = 4'd8; divisor = 4'd4; #10;
    $display("%d\t   | %d\t   | %d\t      | %d", dividend, divisor, quotient, remainder);

    dividend = 4'd15; divisor = 4'd3; #10;
    $display("%d\t   | %d\t   | %d\t      | %d", dividend, divisor, quotient, remainder);

    $finish;
  end

endmodule
OUTPUT
Dividend | Divisor | Quotient | Remainder
13	   |  3	   |  4	      |  1
 9	   |  2	   |  4	      |  1
 7	   |  1	   |  7	      |  0
 8	   |  4	   |  2	      |  0
15	   |  3	   |  5	      |  0
