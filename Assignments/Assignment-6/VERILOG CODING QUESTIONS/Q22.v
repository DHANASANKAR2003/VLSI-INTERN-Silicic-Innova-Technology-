22. Arithmetic Circuits (ALU, Adders, Multipliers, Dividers)
//Design Code

// ---------- 1. 4-bit Ripple Carry Adder ----------
module ripple_carry_adder_4bit(
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] Sum,
    output Cout
);
  wire c1, c2, c3;

  full_adder fa0(A[0], B[0], Cin, Sum[0], c1);
  full_adder fa1(A[1], B[1], c1, Sum[1], c2);
  full_adder fa2(A[2], B[2], c2, Sum[2], c3);
  full_adder fa3(A[3], B[3], c3, Sum[3], Cout);
endmodule

module full_adder(
    input A, B, Cin,
    output Sum, Cout
);
  assign Sum = A ^ B ^ Cin;
  assign Cout = (A & B) | (B & Cin) | (A & Cin);
endmodule

// ---------- 2. 4-bit Carry Look-Ahead Adder ----------
module cla_4bit(
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] Sum,
    output Cout
);
  wire [3:0] G, P;
  wire [3:0] C;

  assign G = A & B;
  assign P = A ^ B;
  assign C[0] = Cin;
  assign C[1] = G[0] | (P[0] & C[0]);
  assign C[2] = G[1] | (P[1] & C[1]);
  assign C[3] = G[2] | (P[2] & C[2]);
  assign Cout = G[3] | (P[3] & C[3]);

  assign Sum[0] = P[0] ^ C[0];
  assign Sum[1] = P[1] ^ C[1];
  assign Sum[2] = P[2] ^ C[2];
  assign Sum[3] = P[3] ^ C[3];
endmodule

// ---------- 3. Bit-Slice ALU (AND, OR, ADD, SUB) ----------
module alu_4bit(
    input [3:0] A,
    input [3:0] B,
    input [1:0] Sel, // 00: AND, 01: OR, 10: ADD, 11: SUB
    output reg [3:0] Result,
    output reg CarryOut
);
  always @(*) begin
    case(Sel)
      2'b00: {CarryOut, Result} = {1'b0, A & B};
      2'b01: {CarryOut, Result} = {1'b0, A | B};
      2'b10: {CarryOut, Result} = A + B;
      2'b11: {CarryOut, Result} = A - B;
    endcase
  end
endmodule

// ---------- 4. 2-bit Booth Multiplier ----------
module booth_multiplier_2bit(
    input signed [1:0] M,   
    input signed [1:0] Q,   
    output signed [3:0] Product
);
  reg signed [3:0] A;   
  reg signed [1:0] Q_reg;
  reg Q_1;
  reg [1:0] count;
  reg signed [3:0] M_ext, temp;

  always @(*) begin
    A = 4'b0000;
    Q_reg = Q;
    Q_1 = 1'b0;
    M_ext = {{2{M[1]}}, M};

    for (count = 0; count < 2; count = count + 1) begin
      case ({Q_reg[0], Q_1})
        2'b01: A = A + M_ext;
        2'b10: A = A - M_ext;
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

// ---------- 5. Divider (2-bit, restoring method) ----------
module divider_2bit(
    input [1:0] dividend,
    input [1:0] divisor,
    output reg [1:0] quotient,
    output reg [1:0] remainder
);
  always @(*) begin
    quotient = 0;
    remainder = 0;
    if (divisor != 0) begin
      remainder = dividend;
      while (remainder >= divisor) begin
        remainder = remainder - divisor;
        quotient = quotient + 1;
      end
    end
  end
endmodule
//Testbench code
module tb_arithmetic;
  reg [3:0] A, B;
  reg [1:0] sel;
  reg [1:0] M, Q;
  reg [1:0] dividend, divisor;
  reg cin;
  wire [3:0] sum1, sum2, alu_result;
  wire cout1, cout2, alu_carry;
  wire signed [3:0] product;
  wire [1:0] quotient, remainder;

  ripple_carry_adder_4bit rca(A, 
                              B, 
                              cin, 
                              sum1, 
                              cout1);
  cla_4bit cla(A, 
               B, 
               cin, 
               sum2, 
               cout2);
  alu_4bit alu(A, 
               B, 
               sel, 
               alu_result, 
               alu_carry);
  booth_multiplier_2bit booth(M, 
                              Q, 
                              product);
  divider_2bit div(dividend, 
                   divisor, 
                   quotient, 
                   remainder);

   initial begin
    $monitor("Time=%0t | A=%b B=%b cin=%b sel=%b | M=%b Q=%b | Div=%b Divisor=%b || RCA Sum=%b Cout=%b | CLA Sum=%b Cout=%b | ALU Result=%b Carry=%b | Booth Product=%b | Quotient=%b Remainder=%b",
             $time, A, B, cin, sel, M, Q, dividend, divisor,
             sum1, cout1, sum2, cout2, alu_result, alu_carry, product, quotient, remainder);
  end

  initial begin
    A = 4'b1010; B = 4'b0101; cin = 0; sel = 2'b10; 
    M = 2'b11; Q = 2'b10;                          
    dividend = 2'b11; divisor = 2'b01;              
    #10;

    A = 4'b0011; B = 4'b1100; cin = 1; sel = 2'b11;
    M = 2'b10; Q = 2'b01;                           
    dividend = 2'b10; divisor = 2'b10;             
    #10;

    A = 4'b0000; B = 4'b0000; cin = 0; sel = 2'b00; 
    M = 2'b01; Q = 2'b01;                          
    dividend = 2'b11; divisor = 2'b10;              
    #10;

    A = 4'b1111; B = 4'b0001; cin = 1; sel = 2'b01; 
    M = 2'b11; Q = 2'b11;                           
    dividend = 2'b01; divisor = 2'b01;              
    #10;

    A = 4'b0110; B = 4'b0011; cin = 0; sel = 2'b10; 
    M = 2'b10; Q = 2'b10;                           
    dividend = 2'b10; divisor = 2'b01;              
    #10;

    $finish;
  end

endmodule

OUTPUT
Time=0  | A=1010 B=0101 cin=0 sel=10 | M=11 Q=10 | Div=11 Divisor=01 || RCA Sum=1111 Cout=0 | CLA Sum=1111 Cout=0 | ALU Result=1111 Carry=0 | Booth Product=0000 | Quotient=11 Remainder=00
Time=10 | A=0011 B=1100 cin=1 sel=11 | M=10 Q=01 | Div=10 Divisor=10 || RCA Sum=0000 Cout=1 | CLA Sum=0000 Cout=1 | ALU Result=0111 Carry=1 | Booth Product=1110 | Quotient=01 Remainder=00
Time=20 | A=0000 B=0000 cin=0 sel=00 | M=01 Q=01 | Div=11 Divisor=10 || RCA Sum=0000 Cout=0 | CLA Sum=0000 Cout=0 | ALU Result=0000 Carry=0 | Booth Product=1111 | Quotient=01 Remainder=01
Time=30 | A=1111 B=0001 cin=1 sel=01 | M=11 Q=11 | Div=01 Divisor=01 || RCA Sum=0001 Cout=1 | CLA Sum=0001 Cout=1 | ALU Result=1111 Carry=0 | Booth Product=0001 | Quotient=01 Remainder=00
Time=40 | A=0110 B=0011 cin=0 sel=10 | M=10 Q=10 | Div=10 Divisor=01 || RCA Sum=1001 Cout=0 | CLA Sum=1001 Cout=0 | ALU Result=1001 Carry=0 | Booth Product=0000 | Quotient=10 Remainder=00
