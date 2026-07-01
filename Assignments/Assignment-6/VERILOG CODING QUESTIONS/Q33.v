33. Implement a 4-bit ALU with arithmetic and logical shift operations.
//Design Code
module alu_4bit_shift (
    input  signed [3:0] A,     
    input  signed [3:0] B,
    input  [2:0] sel,         
    output reg [3:0] result,
    output reg carry_out
);

  always @(*) begin
    carry_out = 0;
    case (sel)
      3'b000: result = A & B;                         
      3'b001: result = A | B;                         
      3'b010: {carry_out, result} = A + B;            
      3'b011: {carry_out, result} = A - B;            
      3'b100: result = A ^ B;                         
      3'b101: result = A << 1;                        
      3'b110: result = A >> 1;                        
      3'b111: result = A >>> 1;                       
      default: result = 4'b0000;
    endcase
  end

endmodule
//Testbench code
module tb_alu_4bit_shift;

  reg  signed [3:0] A, B;
  reg  [2:0] sel;
  wire [3:0] result;
  wire carry_out;

  alu_4bit_shift uut (
    .A(A), 
    .B(B), 
    .sel(sel), 
    .result(result), 
    .carry_out(carry_out)
  );

  initial begin
    $display("A\tB\tSel\t\tOp\tCarry");

    A = 4'b1010; B = 4'b0101;

    sel = 3'b000; #10; 
    $display("%b\t%b\tAND\t\t%b\t%b", A, B, result, carry_out);
    sel = 3'b001; #10; 
    $display("%b\t%b\tOR\t\t%b\t%b", A, B, result, carry_out);
    sel = 3'b010; #10; 
    $display("%b\t%b\tADD\t\t%b\t%b", A, B, result, carry_out);
    sel = 3'b011; #10; 
    $display("%b\t%b\tSUB\t\t%b\t%b", A, B, result, carry_out);
    sel = 3'b100; #10; 
    $display("%b\t%b\tXOR\t\t%b\t%b", A, B, result, carry_out);
    sel = 3'b101; #10; 
    $display("%b\t%b\tLSHIFT\t\t%b\t%b", A, B, result, carry_out);
    sel = 3'b110; #10; 
    $display("%b\t%b\tRSHIFT(Log)\t%b\t%b", A, B, result, carry_out);
    sel = 3'b111; #10; 
    $display("%b\t%b\tRSHIFT(Arth)\t%b\t%b", A, B, result, carry_out);

    $finish;
  end

endmodule

OUTPUT
A	B	Sel		Op	Carry
1010	0101	AND		0000	0
1010	0101	OR		1111	0
1010	0101	ADD		1111	1
1010	0101	SUB		0101	1
1010	0101	XOR		1111	0
1010	0101	LSHIFT		0100	0
1010	0101	RSHIFT(Log)	0101	0
1010	0101	RSHIFT(Arth)	1101	0
