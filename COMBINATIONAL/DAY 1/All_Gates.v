//Design Code
module all_gates(
  input a,b,
  output reg and_gate,or_gate,nand_gate,nor_gate,xor_gate,xnor_gate,a_not,b_not);

  assign and_gate = a&b;
  assign or_gate = a|b;
  assign nand_gate = ~(a&b);
  assign nor_gate = ~(a|b);
  assign xor_gate = a^b;
  assign xnor_gate = ~(a^b);
  assign a_not = ~a;
  assign b_not = ~b;
  
endmodule

//Testbench Code
module all_gates_tb();
  reg a,b;
  wire and_gate,or_gate,nand_gate,nor_gate,xor_gate,xnor_gate,a_not,b_not;
  
  all_gates uut(a,b,and_gate,or_gate,nand_gate,nor_gate,xor_gate,xnor_gate,a_not,b_not);
  initial begin
    a = 1'b0; b = 1'b0;#10
    a = 1'b0; b = 1'b1;#10
    a = 1'b1; b = 1'b0;#10
    a = 1'b1; b = 1'b1;#10
    $finish;
  end
  initial begin
    $dumpfile("all_gates.vcd");
    $dumpvars(1,all_gates_tb);
  end
  always@(*)
    $monitor("Time = %0t \t| a = %b | b = %b | AND = %b | OR = %b | NAND = %b | NOR = %b | XOR = %b | XNOR = %b | A NOT = %b | B NOT = %b",$time,a,b,and_gate,or_gate,nand_gate,nor_gate,xor_gate,xnor_gate,a_not,b_not); 
endmodule
