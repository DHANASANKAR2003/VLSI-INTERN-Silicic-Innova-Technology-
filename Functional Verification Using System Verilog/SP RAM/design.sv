//-----------single port ram-------------//

module sp_ram #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 4, 
  parameter DEPTH = 1 << ADDR_WIDTH
)(
  input  logic clk,
  input  logic rst,
  input  logic en,
  input  logic [ADDR_WIDTH - 1:0] addr,
  input  logic [DATA_WIDTH - 1:0] din,
  output logic [DATA_WIDTH - 1:0] dout
);

  logic [DATA_WIDTH - 1 : 0] mem [0 : DEPTH-1];

  always_ff @(posedge clk) begin
    if (rst)
      ; 
    else if (en)
      mem[addr] <= din; // Write
  end

  assign dout = mem[addr];

endmodule

  
  
