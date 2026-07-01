module test;
  logic [3:0] a;
  logic y;

  initial begin
    a = 4'b1011;
    $display("\n \t The value of a is %0b", a);

    y = !a;  
    $display("\n \t The reduction output of NOT is %0d", y);

    y = |a;  
    $display("\n \t The reduction output of OR is %0b", y);

    y = &a;  
    $display("\n \t The reduction output of AND is %0d", y);

    y = ~|a;  
    $display("\n \t The reduction output of NOR is %0b", y);

    y = ~&a;  
    $display("\n \t The reduction output of NAND is %0b", y);

    y = ^a;  
    $display("\n \t The reduction output of XOR is %0b", y);

    y = ~^a;  
    $display("\n \t The reduction output of XNOR is %0b", y);

  end
endmodule

OUTPUT

The value of a is 1011

 	 The reduction output of NOT is 0

 	 The reduction output of OR is 1

 	 The reduction output of AND is 0

 	 The reduction output of NOR is 0

 	 The reduction output of NAND is 1

 	 The reduction output of XOR is 1

 	 The reduction output of XNOR is 0
