// Boolean Equations
//A_eq_B = A1_XNOR_B1 AND A0_XNOR_B0

//A_gt_B = (A1 AND NOT B1) OR (A1_XNOR_B1 AND A0 AND NOT B0)

//A_lt_B = (NOT A1 AND B1) OR (A1_XNOR_B1 AND NOT A0 AND B0)

// Design Code 
module comparator_2bit_structural(
    input A1, A0,
    input B1, B0,
    output A_eq_B,
    output A_gt_B,
    output A_lt_B
);

// Intermediate wires
wire notA1, notA0, notB1, notB0;
wire A1andB1, notA1andnotB1, A1xnorB1;
wire A0andB0, notA0andnotB0, A0xnorB0;

wire A1andnotB1, A0andnotB0;
wire notA1andB1, notA0andB0;

wire A1eqB1_and_A0eqB0;
wire A1eqB1_and_A0gtB0;
wire A1eqB1_and_A0ltB0;

// NOT gates
not (notA1, A1);
not (notA0, A0);
not (notB1, B1);
not (notB0, B0);

// A1 XNOR B1
and (A1andB1, A1, B1);
and (notA1andnotB1, notA1, notB1);
or  (A1xnorB1, A1andB1, notA1andnotB1);

// A0 XNOR B0
and (A0andB0, A0, B0);
and (notA0andnotB0, notA0, notB0);
or  (A0xnorB0, A0andB0, notA0andnotB0);

// A == B
and (A_eq_B, A1xnorB1, A0xnorB0);

// A > B
and (A1andnotB1, A1, notB1);
and (A0andnotB0, A0, notB0);
and (A1eqB1_and_A0gtB0, A1xnorB1, A0andnotB0);
or  (A_gt_B, A1andnotB1, A1eqB1_and_A0gtB0);

// A < B
and (notA1andB1, notA1, B1);
and (notA0andB0, notA0, B0);
and (A1eqB1_and_A0ltB0, A1xnorB1, notA0andB0);
or  (A_lt_B, notA1andB1, A1eqB1_and_A0ltB0);

endmodule


module tb_comparator_2bit;
  reg A1, A0, B1, B0;
  wire A_eq_B, A_gt_B, A_lt_B;

  // Instantiate the comparator
  comparator_2bit_structural uut (
    .A1(A1), .A0(A0),
    .B1(B1), .B0(B0),
    .A_eq_B(A_eq_B),
    .A_gt_B(A_gt_B),
    .A_lt_B(A_lt_B)
  );

  // Task to display header
  initial begin
    $display(" A1 A0 | B1 B0 || A==B A>B A<B");
    $display("-----------------------------");
  end

  // Apply all input combinations
  integer i, j;
  initial begin
    for (i = 0; i < 4; i = i + 1) begin
      {A1, A0} = i;
      for (j = 0; j < 4; j = j + 1) begin
        {B1, B0} = j;
        #10;
        $display("  %b  %b |  %b  %b ||   %b    %b   %b", A1, A0, B1, B0, A_eq_B, A_gt_B, A_lt_B);
      end
    end
    $finish;
  end

endmodule

//Output
 A1 A0 | B1 B0 || A==B A>B A<B
-----------------------------
  0  0 |  0  0 ||   1    0   0
  0  0 |  0  1 ||   0    0   1
  0  0 |  1  0 ||   0    0   1
  0  0 |  1  1 ||   0    0   1
  0  1 |  0  0 ||   0    1   0
  0  1 |  0  1 ||   1    0   0
  0  1 |  1  0 ||   0    0   1
  0  1 |  1  1 ||   0    0   1
  1  0 |  0  0 ||   0    1   0
  1  0 |  0  1 ||   0    1   0
  1  0 |  1  0 ||   1    0   0
  1  0 |  1  1 ||   0    0   1
  1  1 |  0  0 ||   0    1   0
  1  1 |  0  1 ||   0    1   0
  1  1 |  1  0 ||   0    1   0
  1  1 |  1  1 ||   1    0   0
testbench.sv:34: $finish called at 160 (1s)

