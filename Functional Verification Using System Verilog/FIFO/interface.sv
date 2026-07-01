interface intf(input logic clk);
  logic rst;
  logic wr_en, rd_en;
  logic [7:0] din, dout;
  logic full, empty;
endinterface
