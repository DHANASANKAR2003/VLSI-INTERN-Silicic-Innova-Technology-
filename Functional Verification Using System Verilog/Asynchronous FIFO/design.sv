// Asynchronous FIFO - Clean Simulation
module async_fifo #(
  parameter data_width = 8,     // FIFO data width
  parameter addr_width = 4      // FIFO depth = 2^addr_width
)(
  input  wire [data_width-1:0] data_in,  // Write data
  input  wire wr_en,                     // Write enable
  input  wire wr_clk,                    // Write clock
  input  wire wr_rst,                    // Write reset (sync domain)
  output wire full,                      // FIFO full flag

  output reg  [data_width-1:0] data_out, // Read data
  input  wire rd_en,                     // Read enable
  input  wire rd_clk,                    // Read clock
  input  wire rd_rst,                    // Read reset (sync domain)
  output wire empty                      // FIFO empty flag
);

  localparam depth = 1 << addr_width;    // FIFO depth

  // FIFO memory
  reg [data_width-1:0] mem [0:depth-1];

  // Binary + Gray pointers
  reg [addr_width:0] wr_ptr_bin, wr_ptr_gray;
  reg [addr_width:0] rd_ptr_bin, rd_ptr_gray;

  // Pointer synchronization (2FF sync)
  reg [addr_width:0] wr_ptr_gray_sync_rd1, wr_ptr_gray_sync_rd2;
  reg [addr_width:0] rd_ptr_gray_sync_wr1, rd_ptr_gray_sync_wr2;

  integer i;

  // ---------------- Memory Initialization ----------------
  initial begin
    for (i=0; i<depth; i=i+1) mem[i] = 8'h00;  // Init FIFO with zeros
  end

  // ---------------- Write Domain ----------------
  always @(posedge wr_clk or posedge wr_rst) begin
    if (wr_rst) begin
      wr_ptr_bin         <= 0;
      wr_ptr_gray        <= 0;
      rd_ptr_gray_sync_wr1 <= 0;
      rd_ptr_gray_sync_wr2 <= 0;
    end else begin
      if (wr_en && !full) begin
        mem[wr_ptr_bin[addr_width-1:0]] <= data_in; // Write data
        wr_ptr_bin  <= wr_ptr_bin + 1;              // Increment binary pointer
        wr_ptr_gray <= (wr_ptr_bin + 1) ^ ((wr_ptr_bin + 1) >> 1); // Convert to Gray
      end
      // Sync read pointer into write domain
      rd_ptr_gray_sync_wr1 <= rd_ptr_gray;
      rd_ptr_gray_sync_wr2 <= rd_ptr_gray_sync_wr1;
    end
  end

  // ---------------- Read Domain ----------------
  always @(posedge rd_clk or posedge rd_rst) begin
    if (rd_rst) begin
      rd_ptr_bin         <= 0;
      rd_ptr_gray        <= 0;
      wr_ptr_gray_sync_rd1 <= 0;
      wr_ptr_gray_sync_rd2 <= 0;
      data_out           <= 0;
    end else begin
      if (rd_en && !empty)
        data_out <= mem[rd_ptr_bin[addr_width-1:0]]; // Read data

      if (rd_en && !empty) begin
        rd_ptr_bin  <= rd_ptr_bin + 1;               // Increment binary pointer
        rd_ptr_gray <= (rd_ptr_bin + 1) ^ ((rd_ptr_bin + 1) >> 1); // Convert to Gray
      end

      // Sync write pointer into read domain
      wr_ptr_gray_sync_rd1 <= wr_ptr_gray;
      wr_ptr_gray_sync_rd2 <= wr_ptr_gray_sync_rd1;
    end
  end

  // ---------------- Gray to Binary Conversion ----------------
  function automatic [addr_width:0] gray_to_bin(input [addr_width:0] gray);
    integer i;
    begin
      gray_to_bin[addr_width] = gray[addr_width]; // MSB same
      for(i = addr_width-1; i >= 0; i = i-1)
        gray_to_bin[i] = gray_to_bin[i+1] ^ gray[i]; // XOR cascade
    end
  endfunction

  // Convert pointers to binary for comparison
  wire [addr_width:0] wr_ptr_gray_to_bin          = gray_to_bin(wr_ptr_gray);
  wire [addr_width:0] rd_ptr_gray_sync_wr2_to_bin = gray_to_bin(rd_ptr_gray_sync_wr2);
  wire [addr_width:0] rd_ptr_gray_to_bin          = gray_to_bin(rd_ptr_gray);
  wire [addr_width:0] wr_ptr_gray_sync_rd2_to_bin = gray_to_bin(wr_ptr_gray_sync_rd2);

  // ---------------- FIFO Status ----------------
  assign full  = (wr_ptr_gray_to_bin[addr_width] != rd_ptr_gray_sync_wr2_to_bin[addr_width]) &&
                 (wr_ptr_gray_to_bin[addr_width-1:0] == rd_ptr_gray_sync_wr2_to_bin[addr_width-1:0]); // Full when pointers overlap with MSB difference

//FIFO depth = 8 → addr_width = 3

//Write pointer (bin) = 1000 (MSB = 1, lower = 000)

//Read pointer (bin) = 0000 (MSB = 0, lower = 000)

//Lower bits same, MSB different → FIFO FULL.
 
//Full = write and read pointers are equal in position but different in lap count (MSB).  
  
  assign empty = (rd_ptr_gray_to_bin == wr_ptr_gray_sync_rd2_to_bin); // Empty when pointers equal

endmodule
