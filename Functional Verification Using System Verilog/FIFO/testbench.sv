`include "interface.sv"
`include "test.sv"

module testbench;

  logic clk;
  always #5 clk = ~clk;

  intf intff(clk);

  fifo dut (
    .clk(clk),
    .rst(intff.rst),
    .wr_en(intff.wr_en),
    .rd_en(intff.rd_en),
    .din(intff.din),
    .dout(intff.dout),
    .full(intff.full),
    .empty(intff.empty)
  );


  initial begin
    clk = 0;
    $dumpfile("dump.vcd");
    $dumpvars(0, testbench);
  end
  
  test tst(intff);
endmodule
