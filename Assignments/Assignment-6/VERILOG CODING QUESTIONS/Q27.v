27. Implement an n-bit unsigned multiplier using shift-add algorithm.
//Design Code
module shift_add_multiplier #(parameter N = 4)(
    input clk,
    input rst,
    input start,
    input [N-1:0] A, 
    input [N-1:0] B,  
    output reg [2*N-1:0] Product,
    output reg done
);

  reg [N-1:0] multiplicand;
  reg [N-1:0] multiplier;
  reg [2*N-1:0] temp_product;
  reg [$clog2(N+1)-1:0] count;
  reg running;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      Product <= 0;
      temp_product <= 0;
      count <= 0;
      done <= 0;
      running <= 0;
    end else begin
      if (start && !running) begin
        multiplicand <= A;
        multiplier <= B;
        temp_product <= 0;
        count <= 0;
        done <= 0;
        running <= 1;
      end else if (running) begin
        if (multiplier[0]) begin
          temp_product[N*2-1:N] = temp_product[N*2-1:N] + multiplicand;
        end
        multiplier = multiplier >> 1;
        temp_product = temp_product >> 1;
        count = count + 1;

        if (count == N) begin
          Product <= temp_product;
          done <= 1;
          running <= 0;
        end
      end
    end
  end
endmodule
//Testbench code
module tb_shift_add_multiplier;
  reg clk, rst, start;
  reg [3:0] A, B;
  wire [7:0] Product;
  wire done;

  shift_add_multiplier #(4) uut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .A(A),
    .B(B),
    .Product(Product),
    .done(done)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    rst = 1; start = 0; A = 0; B = 0;
    #10;
    rst = 0;

    A = 4'b1011; B = 4'b0011; 
    start = 1; #10; start = 0;

    wait (done);
    $display("A = %d, B = %d, Product = %d", A, B, Product);

    A = 4'b0110; B = 4'b0101; 
    start = 1; #10; start = 0;

    wait (done);
    $display("A = %d, B = %d, Product = %d", A, B, Product);

    $finish;
  end
endmodule

OUTPUT
A = 11, B =  3, Product =   1
A =  6, B =  5, Product =   1
