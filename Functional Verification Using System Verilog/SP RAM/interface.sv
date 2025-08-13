interface my_inter(input logic clk);
  logic rst;
  logic en;
  logic [3:0]addr;
  logic [7:0]din;
  logic [7:0]dout;
endinterface
