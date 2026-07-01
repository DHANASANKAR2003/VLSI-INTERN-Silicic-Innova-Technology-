interface fifo_if #(parameter data_width = 8)(  // FIFO Interface with parameterized data width
    input logic wr_clk,                          // Write clock
    input logic rd_clk                           // Read clock
);

    // ============================================================
    // Signals
    // ============================================================
    logic [data_width-1:0] data_in;              // FIFO input data
    logic                  wr_rst, rd_rst;       // Write and Read resets
    logic                  wr_en, rd_en;         // Write and Read enables
    logic [data_width-1:0] data_out;             // FIFO output data
    logic                  full, empty;          // FIFO status flags

    // ============================================================
    // Modport for Testbench
    // ============================================================
    modport Tb (
        input  full,                             // Monitor full flag
        input  empty,                            // Monitor empty flag
        input  data_out,                         // Monitor output data
        output wr_rst,                           // Drive write reset
        output rd_rst,                           // Drive read reset
        output wr_en,                            // Drive write enable
        output rd_en,                            // Drive read enable
        output data_in,                          // Drive input data
        input  wr_clk,                           // Access write clock
        input  rd_clk                            // Access read clock
    );

endinterface
