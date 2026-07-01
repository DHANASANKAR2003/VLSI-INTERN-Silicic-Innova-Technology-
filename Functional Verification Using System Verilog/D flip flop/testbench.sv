`include "interface.sv"
`include "test.sv"

module testbench;

  logic clk;
  always #5 clk = ~clk;

  intf intff(clk);

  dff dut (
    .clk(intff.clk),
    .rst(intff.rst),
    .d(intff.d),
    .q(intff.q)
  );

  initial begin
    clk = 0;
    $dumpfile("dump.vcd");
    $dumpvars(0, testbench);
  end
  
  test tst(intff);
endmodule
