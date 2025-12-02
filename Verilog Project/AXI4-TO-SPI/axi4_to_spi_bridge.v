`timescale 1ns/1ps
`include "async_fifo.v"

// ============================================================================
// AXI4 TO SPI BRIDGE - FIXED VERSION
// ============================================================================
module axi4_to_spi_bridge #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter ID_WIDTH = 4,
    parameter FIFO_DEPTH = 16
)(
    input  wire                   m_clk,
    input  wire                   m_rst_n,
    
    input  wire [ADDR_WIDTH-1:0]  m_aw_addr,
    input  wire [ID_WIDTH-1:0]    m_aw_id,
    input  wire [7:0]             m_aw_len,
    input  wire                   m_aw_valid,
    output wire                   m_aw_ready,
    
    input  wire [DATA_WIDTH-1:0]  m_w_data,
    input  wire [3:0]             m_w_strb,
    input  wire                   m_w_last,
    input  wire                   m_w_valid,
    output wire                   m_w_ready,
    
    input  wire                   m_b_ready,
    output reg  [ID_WIDTH-1:0]    m_b_id,
    output reg                    m_b_valid,
    output reg  [1:0]             m_b_resp,
    
    input  wire [ADDR_WIDTH-1:0]  m_ar_addr,
    input  wire [ID_WIDTH-1:0]    m_ar_id,
    input  wire [7:0]             m_ar_len,
    input  wire                   m_ar_valid,
    output wire                   m_ar_ready,
    
    output reg  [DATA_WIDTH-1:0]  m_r_data,
    output reg  [ID_WIDTH-1:0]    m_r_id,
    output reg  [1:0]             m_r_resp,
    output reg                    m_r_last,
    output reg                    m_r_valid,
    input  wire                   m_r_ready,

    input  wire                   spi_clk,
    input  wire                   spi_rst_n,
    
    output reg  [ADDR_WIDTH-1:0]  spi_addr,
    output reg  [DATA_WIDTH-1:0]  spi_wr_data,
    output reg  [3:0]             spi_wr_strb,
    output reg                    spi_wr_valid,
    output reg                    spi_rd_valid,
    input  wire                   spi_ready,
    
    input  wire [DATA_WIDTH-1:0]  spi_rd_data,
    input  wire                   spi_rd_done,
    input  wire                   spi_wr_done,
    input  wire [1:0]             spi_resp
);

    localparam AW_WIDTH = ADDR_WIDTH + ID_WIDTH + 8;
    localparam W_WIDTH = DATA_WIDTH + 5;
    localparam B_WIDTH = ID_WIDTH + 2;
    localparam AR_WIDTH = ADDR_WIDTH + ID_WIDTH + 8;
    localparam R_WIDTH = DATA_WIDTH + ID_WIDTH + 3;

    // FIFOs
    wire [AW_WIDTH-1:0] aw_wr_data = {m_aw_len, m_aw_id, m_aw_addr};
    wire [AW_WIDTH-1:0] aw_rd_data;
    wire aw_full, aw_empty;
    reg aw_rd_en;
    assign m_aw_ready = ~aw_full;

    async_fifo #(.DATA_WIDTH(AW_WIDTH), .DEPTH(FIFO_DEPTH)) aw_fifo (
        .wr_clk(m_clk), .wr_rst_n(m_rst_n), .wr_data(aw_wr_data),
        .wr_en(m_aw_valid & m_aw_ready), .wr_full(aw_full), .wr_level(),
        .rd_clk(spi_clk), .rd_rst_n(spi_rst_n), .rd_data(aw_rd_data),
        .rd_en(aw_rd_en), .rd_empty(aw_empty), .rd_level()
    );

    wire [W_WIDTH-1:0] w_wr_data = {m_w_last, m_w_strb, m_w_data};
    wire [W_WIDTH-1:0] w_rd_data;
    wire w_full, w_empty;
    reg w_rd_en;
    assign m_w_ready = ~w_full;

    async_fifo #(.DATA_WIDTH(W_WIDTH), .DEPTH(FIFO_DEPTH)) w_fifo (
        .wr_clk(m_clk), .wr_rst_n(m_rst_n), .wr_data(w_wr_data),
        .wr_en(m_w_valid & m_w_ready), .wr_full(w_full), .wr_level(),
        .rd_clk(spi_clk), .rd_rst_n(spi_rst_n), .rd_data(w_rd_data),
        .rd_en(w_rd_en), .rd_empty(w_empty), .rd_level()
    );

    wire [B_WIDTH-1:0] b_wr_data;
    wire [B_WIDTH-1:0] b_rd_data;
    wire b_full, b_empty;
    reg b_wr_en;

    async_fifo #(.DATA_WIDTH(B_WIDTH), .DEPTH(FIFO_DEPTH)) b_fifo (
        .wr_clk(spi_clk), .wr_rst_n(spi_rst_n), .wr_data(b_wr_data),
        .wr_en(b_wr_en), .wr_full(b_full), .wr_level(),
        .rd_clk(m_clk), .rd_rst_n(m_rst_n), .rd_data(b_rd_data),
        .rd_en(m_b_valid & m_b_ready), .rd_empty(b_empty), .rd_level()
    );

    wire [AR_WIDTH-1:0] ar_wr_data = {m_ar_len, m_ar_id, m_ar_addr};
    wire [AR_WIDTH-1:0] ar_rd_data;
    wire ar_full, ar_empty;
    reg ar_rd_en;
    assign m_ar_ready = ~ar_full;

    async_fifo #(.DATA_WIDTH(AR_WIDTH), .DEPTH(FIFO_DEPTH)) ar_fifo (
        .wr_clk(m_clk), .wr_rst_n(m_rst_n), .wr_data(ar_wr_data),
        .wr_en(m_ar_valid & m_ar_ready), .wr_full(ar_full), .wr_level(),
        .rd_clk(spi_clk), .rd_rst_n(spi_rst_n), .rd_data(ar_rd_data),
        .rd_en(ar_rd_en), .rd_empty(ar_empty), .rd_level()
    );

    wire [R_WIDTH-1:0] r_wr_data;
    wire [R_WIDTH-1:0] r_rd_data;
    wire r_full, r_empty;
    reg r_wr_en;

    async_fifo #(.DATA_WIDTH(R_WIDTH), .DEPTH(FIFO_DEPTH)) r_fifo (
        .wr_clk(spi_clk), .wr_rst_n(spi_rst_n), .wr_data(r_wr_data),
        .wr_en(r_wr_en), .wr_full(r_full), .wr_level(),
        .rd_clk(m_clk), .rd_rst_n(m_rst_n), .rd_data(r_rd_data),
        .rd_en(m_r_valid & m_r_ready), .rd_empty(r_empty), .rd_level()
    );

    // AXI side
    always @(posedge m_clk or negedge m_rst_n) begin
        if (!m_rst_n) begin
            m_b_valid <= 1'b0;
            m_b_id <= {ID_WIDTH{1'b0}};
            m_b_resp <= 2'b00;
        end else begin
            if (!b_empty && (!m_b_valid || m_b_ready)) begin
                m_b_valid <= 1'b1;
                {m_b_id, m_b_resp} <= b_rd_data;
            end else if (m_b_valid && m_b_ready) begin
                m_b_valid <= 1'b0;
            end
        end
    end

    always @(posedge m_clk or negedge m_rst_n) begin
        if (!m_rst_n) begin
            m_r_valid <= 1'b0;
            m_r_data <= {DATA_WIDTH{1'b0}};
            m_r_id <= {ID_WIDTH{1'b0}};
            m_r_resp <= 2'b00;
            m_r_last <= 1'b0;
        end else begin
            if (!r_empty && (!m_r_valid || m_r_ready)) begin
                m_r_valid <= 1'b1;
                {m_r_last, m_r_id, m_r_resp, m_r_data} <= r_rd_data;
            end else if (m_r_valid && m_r_ready) begin
                m_r_valid <= 1'b0;
            end
        end
    end

    // SPI side state
    reg [ADDR_WIDTH-1:0] wr_curr_addr;
    reg [ID_WIDTH-1:0] wr_curr_id;
    reg [7:0] wr_curr_len;
    reg [7:0] wr_beat_counter;
    
    reg [ADDR_WIDTH-1:0] rd_curr_addr;
    reg [ID_WIDTH-1:0] rd_curr_id;
    reg [7:0] rd_curr_len;
    reg [7:0] rd_beat_counter;

    assign b_wr_data = {wr_curr_id, spi_resp};
    assign r_wr_data = {(rd_beat_counter == rd_curr_len), rd_curr_id, spi_resp, spi_rd_data};

    // Write FSM - FIXED
    localparam WR_IDLE      = 3'd0;
    localparam WR_GET_AW    = 3'd1;
    localparam WR_WAIT_W    = 3'd2;
    localparam WR_GET_W     = 3'd3;
    localparam WR_SPI_REQ   = 3'd4;
    localparam WR_SPI_WAIT  = 3'd5;
    localparam WR_SEND_RESP = 3'd6;
    localparam WR_WAIT_FOR_W = 3'd7;

    reg [2:0] wr_state;
    reg rd_trans_active;

    // Registered signals
    reg [ADDR_WIDTH-1:0] latched_addr;
    reg [ID_WIDTH-1:0] latched_id;
    reg [7:0] latched_len;
    reg [W_WIDTH-1:0] latched_wdata;
    reg latched_wdata_valid;

    always @(posedge spi_clk or negedge spi_rst_n) begin
        if (!spi_rst_n) begin
            wr_state <= WR_IDLE;
            aw_rd_en <= 1'b0;
            w_rd_en <= 1'b0;
            b_wr_en <= 1'b0;
            spi_wr_valid <= 1'b0;
            spi_addr <= {ADDR_WIDTH{1'b0}};
            spi_wr_data <= {DATA_WIDTH{1'b0}};
            spi_wr_strb <= 4'b0000;
            wr_curr_addr <= {ADDR_WIDTH{1'b0}};
            wr_curr_id <= {ID_WIDTH{1'b0}};
            wr_curr_len <= 8'd0;
            wr_beat_counter <= 8'd0;
            latched_addr <= {ADDR_WIDTH{1'b0}};
            latched_id <= {ID_WIDTH{1'b0}};
            latched_len <= 8'd0;
            latched_wdata <= {W_WIDTH{1'b0}};
            latched_wdata_valid <= 1'b0;
        end else begin
            aw_rd_en <= 1'b0;
            w_rd_en <= 1'b0;
            b_wr_en <= 1'b0;

            case (wr_state)
                WR_IDLE: begin
                    latched_wdata_valid <= 1'b0;
                    if (!aw_empty && !w_empty && !rd_trans_active) begin
                        wr_state <= WR_GET_AW;
                    end
                end

                WR_GET_AW: begin
                    latched_addr <= aw_rd_data[ADDR_WIDTH-1:0];
                    latched_id <= aw_rd_data[ADDR_WIDTH +: ID_WIDTH];
                    latched_len <= aw_rd_data[ADDR_WIDTH+ID_WIDTH +: 8];
                    
                    wr_curr_addr <= aw_rd_data[ADDR_WIDTH-1:0];
                    wr_curr_id <= aw_rd_data[ADDR_WIDTH +: ID_WIDTH];
                    wr_curr_len <= aw_rd_data[ADDR_WIDTH+ID_WIDTH +: 8];
                    wr_beat_counter <= 8'd0;
                    
                    aw_rd_en <= 1'b1;
                    wr_state <= WR_WAIT_W;
                end

                WR_WAIT_W: begin
                    wr_state <= WR_GET_W;
                end

                WR_GET_W: begin
                    latched_wdata <= w_rd_data;
                    latched_wdata_valid <= 1'b1;
                    w_rd_en <= 1'b1;
                    
                    wr_state <= WR_SPI_REQ;
                end

                WR_SPI_REQ: begin
                    if (spi_ready && !spi_wr_valid && latched_wdata_valid) begin
                        spi_addr <= wr_curr_addr + (wr_beat_counter << 2);
                        spi_wr_data <= latched_wdata[DATA_WIDTH-1:0];
                        spi_wr_strb <= latched_wdata[DATA_WIDTH +: 4];
                        spi_wr_valid <= 1'b1;
                        latched_wdata_valid <= 1'b0;
                        wr_state <= WR_SPI_WAIT;
                    end
                end

                WR_SPI_WAIT: begin
                    if (spi_wr_done) begin
                        spi_wr_valid <= 1'b0;
                        
                        if (latched_wdata[DATA_WIDTH+4]) begin
                            wr_state <= WR_SEND_RESP;
                        end else begin
                            wr_beat_counter <= wr_beat_counter + 1;
                            if (!w_empty) begin
                                wr_state <= WR_GET_W;
                            end else begin
                                wr_state <= WR_WAIT_FOR_W;
                            end
                        end
                    end
                end
                
                WR_WAIT_FOR_W: begin
                    if (!w_empty) begin
                        wr_state <= WR_GET_W;
                    end
                end

                WR_SEND_RESP: begin
                    if (!b_full) begin
                        b_wr_en <= 1'b1;
                        wr_state <= WR_IDLE;
                    end
                end

                default: wr_state <= WR_IDLE;
            endcase
        end
    end

    // Read FSM
    localparam RD_IDLE       = 3'd0;
    localparam RD_GET_AR     = 3'd1;
    localparam RD_SPI_REQ    = 3'd2;
    localparam RD_SPI_WAIT   = 3'd3;
    localparam RD_SEND_DATA  = 3'd4;
    localparam RD_CHECK_LAST = 3'd5;

    reg [2:0] rd_state;

    always @(posedge spi_clk or negedge spi_rst_n) begin
        if (!spi_rst_n) begin
            rd_state <= RD_IDLE;
            ar_rd_en <= 1'b0;
            r_wr_en <= 1'b0;
            spi_rd_valid <= 1'b0;
            rd_trans_active <= 1'b0;
            rd_curr_addr <= {ADDR_WIDTH{1'b0}};
            rd_curr_id <= {ID_WIDTH{1'b0}};
            rd_curr_len <= 8'd0;
            rd_beat_counter <= 8'd0;
        end else begin
            ar_rd_en <= 1'b0;
            r_wr_en <= 1'b0;

            case (rd_state)
                RD_IDLE: begin
                    rd_trans_active <= 1'b0;
                    if (!ar_empty && wr_state == WR_IDLE) begin
                        rd_trans_active <= 1'b1;
                        rd_state <= RD_GET_AR;
                    end
                end

                RD_GET_AR: begin
                    rd_curr_addr <= ar_rd_data[ADDR_WIDTH-1:0];
                    rd_curr_id <= ar_rd_data[ADDR_WIDTH +: ID_WIDTH];
                    rd_curr_len <= ar_rd_data[ADDR_WIDTH+ID_WIDTH +: 8];
                    ar_rd_en <= 1'b1;
                    rd_beat_counter <= 8'd0;
                    rd_state <= RD_SPI_REQ;
                end

                RD_SPI_REQ: begin
                    if (spi_ready && !spi_rd_valid) begin
                        spi_addr <= rd_curr_addr + (rd_beat_counter << 2);
                        spi_rd_valid <= 1'b1;
                        rd_state <= RD_SPI_WAIT;
                    end
                end

                RD_SPI_WAIT: begin
                    if (spi_rd_done) begin
                        spi_rd_valid <= 1'b0;
                        rd_state <= RD_SEND_DATA;
                    end
                end

                RD_SEND_DATA: begin
                    if (!r_full) begin
                        r_wr_en <= 1'b1;
                        rd_state <= RD_CHECK_LAST;
                    end
                end

                RD_CHECK_LAST: begin
                    if (rd_beat_counter >= rd_curr_len) begin
                        rd_state <= RD_IDLE;
                    end else begin
                        rd_beat_counter <= rd_beat_counter + 1;
                        rd_state <= RD_SPI_REQ;
                    end
                end

                default: rd_state <= RD_IDLE;
            endcase
        end
    end

endmodule
