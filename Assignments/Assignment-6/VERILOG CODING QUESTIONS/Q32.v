32. Design a 4-bit ALU with AND, OR, ADD, SUB, XOR operations.
//Design Code
module alu_4bit (
    input  [3:0] A,
    input  [3:0] B,
    input  [2:0] sel,
    output reg [3:0] result,
    output reg carry_out
);

  always @(*) 
    begin
      case (sel)
        3'b000: 
          begin 
            result = A & B;
            carry_out = 0;
          end

        3'b001: 
          begin 
            result = A | B;
            carry_out = 0;
          end

       3'b010: 
         begin 
           {carry_out, result} = A + B;
         end

       3'b011: 
         begin 
           {carry_out, result} = A - B;
         end

       3'b100: 
         begin
           result = A ^ B;
           carry_out = 0;
         end

      default: 
        begin
           result = 4'b0000;
           carry_out = 0;
        end
      endcase
    end

endmodule

//Testbench code
module tb_alu_4bit;

  reg [3:0] A, B;
  reg [2:0] sel;
  wire [3:0] result;
  wire carry_out;

  alu_4bit uut (
    .A(A),
    .B(B),
    .sel(sel),
    .result(result),
    .carry_out(carry_out)
  );

  initial begin
    $display("A\tB\tSEL\tResult\tCarry");
    
    A = 4'b1010; B = 4'b0101; sel = 3'b000; #10; 
    $display("%b\t%b\tAND  \t%b\t%b", A, B, result, carry_out);
    
    sel = 3'b001; #10; 
    $display("%b\t%b\tOR   \t%b\t%b", A, B, result, carry_out);
    
    sel = 3'b010; #10; 
    $display("%b\t%b\tADD  \t%b\t%b", A, B, result, carry_out);
    
    sel = 3'b011; #10; 
    $display("%b\t%b\tSUB  \t%b\t%b", A, B, result, carry_out);
    
    sel = 3'b100; #10; 
    $display("%b\t%b\tXOR  \t%b\t%b", A, B, result, carry_out);
    
    $finish;
  end

endmodule

OUTPUT
A	B	SEL	Result	Carry
1010	0101	AND  	0000	0
1010	0101	OR   	1111	0
1010	0101	ADD  	1111	0
1010	0101	SUB  	0101	0
1010	0101	XOR  	1111	0
