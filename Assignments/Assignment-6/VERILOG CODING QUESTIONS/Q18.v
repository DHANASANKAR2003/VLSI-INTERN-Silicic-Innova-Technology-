18. Implement a 2-bit booth multiplier.
//Design Code
module booth_multiplier_2bit(
    input  signed [1:0] M,   
    input  signed [1:0] Q,   
    output signed [3:0] Product
);

  reg signed [3:0] A;   
  reg signed [1:0] Q_reg;
  reg Q_1;
  reg [1:0] count;

  reg signed [3:0] M_ext; 
  reg signed [3:0] Q_ext;
  reg signed [3:0] temp;

  always @(*) begin
    A = 4'b0000;
    Q_reg = Q;
    Q_1 = 1'b0;
    M_ext = {{2{M[1]}}, M};  
    Q_ext = {{2{Q[1]}}, Q};  

    for (count = 0; count < 2; count = count + 1) begin
      case ({Q_reg[0], Q_1})
        2'b01: A = A + M_ext; 
        2'b10: A = A - M_ext; 
        default: ;             
      endcase

      temp = {A, Q_reg};      
      temp = temp >>> 1;     
      A = temp[5:2];
      Q_reg = temp[1:0];
      Q_1 = temp[0];
    end
  end

  assign Product = {A, Q_reg};

endmodule
//Testbench code
`timescale 1ns/1ps

module tb_booth_multiplier_2bit;
  reg signed [1:0] M, Q;
  wire signed [3:0] Product;

  booth_multiplier_2bit uut (
    .M(M),
    .Q(Q),
    .Product(Product)
  );

  initial begin
    $display("Time\tM\tQ\tProduct");
    $monitor("%0t\t%d\t%d\t%d", $time, M, Q, Product);

    M =  2; Q =  1; #10;  
    M =  1; Q = -1; #10;  
    M = -2; Q =  1; #10; 
    M = -1; Q = -2; #10; 
    M =  0; Q = -1; #10;  
    M =  1; Q =  2; #10;  
    M = -2; Q = -2; #10;  
    M =  2; Q =  2; #10;

    $finish;
  end
endmodule

OUTPUT
Time	 M	 Q	Product
0   	-2	 1	-2
10000	 1	-1	-1
20000	-2	 1	-2
30000	-1	-2	 0
40000	 0	-1	 0
50000	 1	-2	 0
60000	-2	-2	 0
