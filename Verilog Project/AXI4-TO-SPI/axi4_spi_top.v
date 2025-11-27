`timescale 1ns/1ps
module axi4_spi_top #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter ID_WIDTH = 4,
    parameter SPI_CLK_DIV = 4,
    parameter NUM_REGS = 256
)(
    // AXI Clock domain
    input  wire                  m_clk,
    input  wire                  m_rst_n,
    input  wire                  start_read,
    input  wire                  start_write,
    input  wire [ADDR_WIDTH-1:0] m_address,
    input  wire [DATA_WIDTH-1:0] m_w_data,
    input  wire [3:0]            m_w_strb,
    input  wire [ID_WIDTH-1:0]   m_id,
    input  wire [7:0]            m_len,

    // SPI clock domain
    input  wire                  spi_clk,
    input  wire                  spi_rst_n,

    // SPI Physical Interface
    output wire spi_cs_n,
    output wire spi_sclk,
    output wire spi_mosi,
    input  wire spi_miso
);

    // AXI4 Master to Bridge signals
    wire [ADDR_WIDTH-1:0]  m_aw_addr;
    wire [ADDR_WIDTH-1:0]  m_ar_addr;
    wire [DATA_WIDTH-1:0]  m_w_data_int;
    wire [DATA_WIDTH-1:0]  m_r_data;
    wire [3:0]             m_w_strb_int;
    wire [ID_WIDTH-1:0]    m_aw_id;
    wire [ID_WIDTH-1:0]    m_ar_id;
    wire [ID_WIDTH-1:0]    m_b_id;
    wire [ID_WIDTH-1:0]    m_r_id;
    wire [7:0]             m_aw_len;
    wire [7:0]             m_ar_len;

    wire                   m_aw_valid;
    wire                   m_w_valid;
    wire                   m_w_last;
    wire                   m_b_ready;
    wire [1:0]             m_b_resp;
    wire                   m_b_valid;
    wire                   m_ar_valid;
    wire                   m_r_ready;
    wire                   m_r_valid;
    wire                   m_r_last;
    wire [1:0]             m_r_resp;

    wire                   m_aw_ready;
    wire                   m_w_ready;
    wire                   m_ar_ready;

    // Bridge to SPI Master signals
    wire [ADDR_WIDTH-1:0]  spi_addr;
    wire [DATA_WIDTH-1:0]  spi_wr_data;
    wire [3:0]             spi_wr_strb;
    wire                   spi_wr_valid;
    wire                   spi_rd_valid;
    wire                   spi_ready;
    
    wire [DATA_WIDTH-1:0]  spi_rd_data;
    wire                   spi_rd_done;
    wire                   spi_wr_done;
    wire [1:0]             spi_resp;

    // AXI4 Master
    axi4_master #(
        .ADDRESS    (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .ID_WIDTH   (ID_WIDTH)
    ) u_axi_master (
        .ACLK        (m_clk),
        .ARESETN     (m_rst_n),
        .START_READ  (start_read),
        .START_WRITE (start_write),
        .address     (m_address),
        .W_data      (m_w_data),
        .W_strb      (m_w_strb),
        .axi_id      (m_id),
        .burst_len   (m_len),

        .M_ARADDR    (m_ar_addr),
        .M_ARID      (m_ar_id),
        .M_ARLEN     (m_ar_len),
        .M_ARVALID   (m_ar_valid),
        .M_ARREADY   (m_ar_ready),
        
        .M_RDATA     (m_r_data),
        .M_RID       (m_r_id),
        .M_RRESP     (m_r_resp),
        .M_RLAST     (m_r_last),
        .M_RVALID    (m_r_valid),
        .M_RREADY    (m_r_ready),

        .M_AWADDR    (m_aw_addr),
        .M_AWID      (m_aw_id),
        .M_AWLEN     (m_aw_len),
        .M_AWVALID   (m_aw_valid),
        .M_AWREADY   (m_aw_ready),
        
        .M_WDATA     (m_w_data_int),
        .M_WSTRB     (m_w_strb_int),
        .M_WLAST     (m_w_last),
        .M_WVALID    (m_w_valid),
        .M_WREADY    (m_w_ready),
        
        .M_BID       (m_b_id),
        .M_BRESP     (m_b_resp),
        .M_BVALID    (m_b_valid),
        .M_BREADY    (m_b_ready)
    );

    // AXI4 to SPI Bridge with CDC
    axi4_to_spi_bridge #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .ID_WIDTH   (ID_WIDTH),
        .FIFO_DEPTH (16)
    ) u_bridge (
        .m_clk      (m_clk),
        .m_rst_n    (m_rst_n),

        .m_aw_addr  (m_aw_addr),
        .m_aw_id    (m_aw_id),
        .m_aw_len   (m_aw_len),
        .m_aw_valid (m_aw_valid),
        .m_aw_ready (m_aw_ready),

        .m_w_data   (m_w_data_int),
        .m_w_strb   (m_w_strb_int),
        .m_w_last   (m_w_last),
        .m_w_valid  (m_w_valid),
        .m_w_ready  (m_w_ready),

        .m_b_id     (m_b_id),
        .m_b_resp   (m_b_resp),
        .m_b_valid  (m_b_valid),
        .m_b_ready  (m_b_ready),

        .m_ar_addr  (m_ar_addr),
        .m_ar_id    (m_ar_id),
        .m_ar_len   (m_ar_len),
        .m_ar_valid (m_ar_valid),
        .m_ar_ready (m_ar_ready),

        .m_r_data   (m_r_data),
        .m_r_id     (m_r_id),
        .m_r_resp   (m_r_resp),
        .m_r_last   (m_r_last),
        .m_r_valid  (m_r_valid),
        .m_r_ready  (m_r_ready),

        .spi_clk      (spi_clk),
        .spi_rst_n    (spi_rst_n),
        
        .spi_addr     (spi_addr),
        .spi_wr_data  (spi_wr_data),
        .spi_wr_strb  (spi_wr_strb),
        .spi_wr_valid (spi_wr_valid),
        .spi_rd_valid (spi_rd_valid),
        .spi_ready    (spi_ready),
        
        .spi_rd_data  (spi_rd_data),
        .spi_rd_done  (spi_rd_done),
        .spi_wr_done  (spi_wr_done),
        .spi_resp     (spi_resp)
    );

    // SPI Master
    spi_master #(
        .DATA_WIDTH  (DATA_WIDTH),
        .ADDR_WIDTH  (ADDR_WIDTH),
        .SPI_CLK_DIV (SPI_CLK_DIV),
        .NUM_REGS    (NUM_REGS)
    ) u_spi_master (
        .clk           (spi_clk),
        .rst_n         (spi_rst_n),
        
        .cmd_addr      (spi_addr),
        .cmd_wr_data   (spi_wr_data),
        .cmd_wr_strb   (spi_wr_strb),
        .cmd_wr_valid  (spi_wr_valid),
        .cmd_rd_valid  (spi_rd_valid),
        .cmd_ready     (spi_ready),
        
        .resp_rd_data  (spi_rd_data),
        .resp_rd_done  (spi_rd_done),
        .resp_wr_done  (spi_wr_done),
        .resp_status   (spi_resp),
        
        .spi_sclk      (spi_sclk),
        .spi_cs_n      (spi_cs_n),
        .spi_mosi      (spi_mosi),
        .spi_miso      (spi_miso)
    );

    // SPI Slave (with internal memory)
    spi_slave #(
        .DATA_WIDTH  (DATA_WIDTH),
        .ADDR_WIDTH  (ADDR_WIDTH),
        .NUM_REGS    (NUM_REGS)
    ) u_spi_slave (
        .sclk        (spi_sclk),
        .cs_n        (spi_cs_n),
        .mosi        (spi_mosi),
        .miso        (spi_miso)
    );

endmodule

