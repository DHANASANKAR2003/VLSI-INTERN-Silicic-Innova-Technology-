`timescale 1ns/1ps

// ============================================================================
// ASYNC FIFO - Standard implementation with combinational read
// ============================================================================
module async_fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 16,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)(
    input  wire                   wr_clk,
    input  wire                   wr_rst_n,
    input  wire [DATA_WIDTH-1:0]  wr_data,
    input  wire                   wr_en,
    output wire                   wr_full,
    output wire [ADDR_WIDTH:0]    wr_level,
    
    input  wire                   rd_clk,
    input  wire                   rd_rst_n,
    output wire [DATA_WIDTH-1:0]  rd_data,
    input  wire                   rd_en,
    output wire                   rd_empty,
    output wire [ADDR_WIDTH:0]    rd_level
);
    // Dual-port memory
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    
    // Binary and Gray code pointers
    reg [ADDR_WIDTH:0] wr_ptr_bin,  wr_ptr_gray;
    reg [ADDR_WIDTH:0] rd_ptr_bin,  rd_ptr_gray;
    
    // Synchronized Gray pointers
    reg [ADDR_WIDTH:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;
    reg [ADDR_WIDTH:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;
    
    wire [ADDR_WIDTH:0] rd_ptr_bin_sync;
    wire [ADDR_WIDTH:0] wr_ptr_bin_sync;
    
    function [ADDR_WIDTH:0] bin2gray;
        input [ADDR_WIDTH:0] bin;
        bin2gray = bin ^ (bin >> 1);
    endfunction
    
    function [ADDR_WIDTH:0] gray2bin;
        input [ADDR_WIDTH:0] gray;
        integer i;
        reg [ADDR_WIDTH:0] tmp;
        begin
            tmp[ADDR_WIDTH] = gray[ADDR_WIDTH];
            for(i = ADDR_WIDTH-1; i >= 0; i = i - 1)
                tmp[i] = tmp[i+1] ^ gray[i];
            gray2bin = tmp;
        end
    endfunction
    
    // Write logic
    wire [ADDR_WIDTH:0] wr_ptr_bin_next  = wr_ptr_bin + 1;
    wire [ADDR_WIDTH:0] wr_ptr_gray_next = bin2gray(wr_ptr_bin_next);
    
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if(!wr_rst_n) begin
            wr_ptr_bin  <= 0;
            wr_ptr_gray <= 0;
        end else if(wr_en && !wr_full) begin
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr_bin  <= wr_ptr_bin_next;
            wr_ptr_gray <= wr_ptr_gray_next;
        end
    end
    
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if(!wr_rst_n) begin
            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;
        end else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end
    
    assign rd_ptr_bin_sync = gray2bin(rd_ptr_gray_sync2);
    assign wr_full = (wr_ptr_gray_next == {~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1], rd_ptr_gray_sync2[ADDR_WIDTH-2:0]});
    assign wr_level = wr_ptr_bin - rd_ptr_bin_sync;
    
    // Read logic - COMBINATIONAL output
    wire [ADDR_WIDTH:0] rd_ptr_bin_next  = rd_ptr_bin + 1;
    wire [ADDR_WIDTH:0] rd_ptr_gray_next = bin2gray(rd_ptr_bin_next);
    
    assign rd_data = mem[rd_ptr_bin[ADDR_WIDTH-1:0]];  // Combinational read
    
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if(!rd_rst_n) begin
            rd_ptr_bin  <= 0;
            rd_ptr_gray <= 0;
        end else if(rd_en && !rd_empty) begin
            rd_ptr_bin  <= rd_ptr_bin_next;
            rd_ptr_gray <= rd_ptr_gray_next;
        end
    end
    
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if(!rd_rst_n) begin
            wr_ptr_gray_sync1 <= 0;
            wr_ptr_gray_sync2 <= 0;
        end else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end
    
    assign wr_ptr_bin_sync = gray2bin(wr_ptr_gray_sync2);
    assign rd_empty = (rd_ptr_gray == wr_ptr_gray_sync2);
    assign rd_level = wr_ptr_bin_sync - rd_ptr_bin;
endmodule
