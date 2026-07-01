`include "interface.sv"
`include "test.sv"

module testbench;
  logic clk = 0;
  always #5 clk = ~clk;
  
  my_inter interf(clk);
  test tst(interf);
  
  sp_ram dut (
    .clk(clk),
    .rst(interf.rst),
    .en(interf.en),
    .addr(interf.addr), 
    .din(interf.din),
    .dout(interf.dout)
  );
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule

  
