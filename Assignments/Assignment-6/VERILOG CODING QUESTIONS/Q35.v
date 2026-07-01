35. Implement a 4-bit divider using non-restoring division.
//Design Code
module non_restoring_divider_4bit (
    input  [3:0] dividend,
    input  [3:0] divisor,
    output reg [3:0] quotient,
    output reg [3:0] remainder
);
  reg signed [4:0] A;     
  reg [3:0] Q;           
  reg [3:0] M;            
  integer i;

  always @(*) begin
    A = 5'd0;
    Q = dividend;
    M = divisor;

    for (i = 0; i < 4; i = i + 1) begin
      {A, Q} = {A, Q} << 1;

      if (A[4] == 0)
        A = A - M;
      else
        A = A + M;

      if (A[4] == 0)
        Q[0] = 1;
      else
        Q[0] = 0;
    end

    if (A[4] == 1)
      A = A + M;  

    quotient = Q;
    remainder = A[3:0];
  end
endmodule

//Testbench code
module tb_non_restoring;
  reg [3:0] dividend, divisor;
  wire [3:0] quotient, remainder;

  non_restoring_divider_4bit uut (
    .dividend(dividend),
    .divisor(divisor),
    .quotient(quotient),
    .remainder(remainder)
  );

  initial begin
    $display("Dividend | Divisor | Quotient | Remainder");
    
    dividend = 13; divisor = 3; #10;
    $display("   %d     |   %d     |    %d     |    %d", dividend, divisor, quotient, remainder);
    
    dividend = 4; divisor = 2; #10;
    $display("   %d     |   %d     |    %d     |    %d", dividend, divisor, quotient, remainder);

    dividend = 7; divisor = 1; #10;
    $display("   %d     |   %d     |    %d     |    %d", dividend, divisor, quotient, remainder);

    dividend = 15; divisor = 4; #10;
    $display("   %d     |   %d     |    %d     |    %d", dividend, divisor, quotient, remainder);

    dividend = 8; divisor = 3; #10;
    $display("   %d     |   %d     |    %d     |    %d", dividend, divisor, quotient, remainder);

    $finish;
  end
endmodule

OUTPUT
Dividend | Divisor | Quotient | Remainder
   13     |    3     |     4     |     1
    4     |    2     |     2     |     0
    7     |    1     |     7     |     0
   15     |    4     |     3     |     3
    8     |    3     |     2     |     2
