26. Implement a serial adder with a shift register.
//Design Code
module serial_adder (
  input wire clk,
  input wire rst,
  input wire start,
  input wire [3:0] A,
  input wire [3:0] B,
  output reg [3:0] Sum,
  output reg done
);

  reg [3:0] reg_A, reg_B;
  reg [2:0] count;
  reg carry;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      reg_A <= 0;
      reg_B <= 0;
      Sum <= 0;
      carry <= 0;
      count <= 0;
      done <= 0;
    end else if (start && !done) begin
      reg_A <= A;
      reg_B <= B;
      Sum <= 0;
      carry <= 0;
      count <= 0;
      done <= 0;
    end else if (!done) begin
      {carry, Sum[count]} <= reg_A[0] + reg_B[0] + carry;
      reg_A <= reg_A >> 1;
      reg_B <= reg_B >> 1;

      count <= count + 1;

      if (count == 3) begin
        done <= 1;
      end
    end
  end
endmodule
//Testbench code
module tb_serial_adder;
  reg clk, rst, start;
  reg [3:0] A, B;
  wire [3:0] Sum;
  wire done;

  serial_adder uut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .A(A),
    .B(B),
    .Sum(Sum),
    .done(done)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 0; rst = 1; start = 0; A = 0; B = 0;
    #10 rst = 0;

    A = 4'b1010; B = 4'b0101; start = 1; #10;
    start = 0;

    wait(done);
    $display("A = %b, B = %b, Sum = %b", A, B, Sum);

    A = 4'b1100; B = 4'b0011; start = 1; #10;
    start = 0;

    wait(done);
    $display("A = %b, B = %b, Sum = %b", A, B, Sum);

    $finish;
  end
endmodule

OUTPUT
A = 1010, B = 0101, Sum = 1111
A = 1100, B = 0011, Sum = 1111
