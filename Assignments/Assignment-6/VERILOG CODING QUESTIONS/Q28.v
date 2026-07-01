28. Implement a 4-bit Booth’s multiplier.
//Design Code
module booth_multiplier_4bit (
    input clk,
    input start,
    input signed [3:0] M,  
    input signed [3:0] Q, 
    output reg signed [7:0] Product,
    output reg done
);
  reg signed [4:0] A;
  reg signed [4:0] S;
  reg [8:0] P; 
  reg [2:0] count;

  always @(posedge clk) begin
    if (start) begin
      A <= {M[3], M};         
      S <= {~M[3], -M};       
      P <= {5'b0, Q, 1'b0};   
      count <= 4;
      done <= 0;
    end else if (count > 0) begin
      case (P[1:0])
        2'b01: P[8:4] = P[8:4] + A; 
        2'b10: P[8:4] = P[8:4] + S; 
        default: ; 
      endcase

      
      P = {P[8], P[8:1]}; 
      count = count - 1;

      if (count == 0) begin
        Product <= P[8:1]; 
        done <= 1;
      end
    end
  end
endmodule
//Testbench code
module tb_booth_multiplier_4bit;
  reg clk, start;
  reg signed [3:0] M, Q;
  wire signed [7:0] Product;
  wire done;

  booth_multiplier_4bit uut (
    .clk(clk),
    .start(start),
    .M(M),
    .Q(Q),
    .Product(Product),
    .done(done)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    M = 4'sd3; Q = -4'sd2; start = 1; #10; start = 0;
    wait(done);
    $display("M=%d, Q=%d => Product=%d", M, Q, Product);

    M = -4'sd4; Q = -4'sd3; start = 1; #10; start = 0;
    wait(done);
    $display("M=%d, Q=%d => Product=%d", M, Q, Product);

    M = 4'sd5; Q = 4'sd2; start = 1; #10; start = 0;
    wait(done);
    $display("M=%d, Q=%d => Product=%d", M, Q, Product);

    $finish;
  end
endmodule

OUTPUT
M= 3, Q=-2 => Product=  -3
M=-4, Q=-3 => Product=  -3
M= 5, Q= 2 => Product=   5

