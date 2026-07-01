// axi_lite_status_regs.v
// Status/error register bank.
//   REG0 (0x00): DEVICE_ID    - RO, fixed identifier, used by host to confirm
//                               it is talking to the right design after programming
//   REG1 (0x04): STATUS_FLAGS - RO, live status bits (protocol error, decode
//                               error, timeout error, reset-in-progress)
//   REG2 (0x08): ERROR_CLEAR  - WO, writing 1 to a bit clears the
//                               corresponding latched error flag
//   REG3 (0x0C): VERSION      - RO, firmware/build version, fixed value

module axi_lite_status_regs #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter [31:0] DEVICE_ID_VAL = 32'hA5A5_0009, // matches "Project 9" id scheme
    parameter [31:0] VERSION_VAL   = 32'h0001_0000  // v1.0
) (
    input  wire                      clk,
    input  wire                      rst_n,

    input  wire [ADDR_WIDTH-1:0]     s_axi_awaddr,
    input  wire                      s_axi_awvalid,
    output wire                      s_axi_awready,
    input  wire [DATA_WIDTH-1:0]     s_axi_wdata,
    input  wire [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input  wire                      s_axi_wvalid,
    output wire                      s_axi_wready,
    output wire [1:0]                s_axi_bresp,
    output wire                      s_axi_bvalid,
    input  wire                      s_axi_bready,
    input  wire [ADDR_WIDTH-1:0]     s_axi_araddr,
    input  wire                      s_axi_arvalid,
    output wire                      s_axi_arready,
    output wire [DATA_WIDTH-1:0]     s_axi_rdata,
    output wire [1:0]                s_axi_rresp,
    output wire                      s_axi_rvalid,
    input  wire                      s_axi_rready,

    // Live status inputs, aggregated from other RTL blocks
    input  wire                      protocol_error_in,
    input  wire                      decode_error_in,
    input  wire                      timeout_error_in,
    input  wire                      reset_in_progress_in
);

    // REG0=RO, REG1=RO, REG2=WO, REG3=RO
    localparam [7:0] STATUS_POLICY = 8'b01_10_01_01;

    wire [31:0] status_flags = {28'h0,
                                 reset_in_progress_in,
                                 timeout_error_in,
                                 decode_error_in,
                                 protocol_error_in};

    axi_lite_register_block #(
        .ADDR_WIDTH   (ADDR_WIDTH),
        .DATA_WIDTH   (DATA_WIDTH),
        .RESET_VAL0   (DEVICE_ID_VAL),
        .RESET_VAL1   (32'h0000_0000),
        .RESET_VAL2   (32'h0000_0000),
        .RESET_VAL3   (VERSION_VAL),
        .ACCESS_POLICY(STATUS_POLICY)
    ) u_reg_block (
        .clk             (clk),
        .rst_n           (rst_n),
        .s_axi_awaddr    (s_axi_awaddr),
        .s_axi_awvalid   (s_axi_awvalid),
        .s_axi_awready   (s_axi_awready),
        .s_axi_wdata     (s_axi_wdata),
        .s_axi_wstrb     (s_axi_wstrb),
        .s_axi_wvalid    (s_axi_wvalid),
        .s_axi_wready    (s_axi_wready),
        .s_axi_bresp     (s_axi_bresp),
        .s_axi_bvalid    (s_axi_bvalid),
        .s_axi_bready    (s_axi_bready),
        .s_axi_araddr    (s_axi_araddr),
        .s_axi_arvalid   (s_axi_arvalid),
        .s_axi_arready   (s_axi_arready),
        .s_axi_rdata     (s_axi_rdata),
        .s_axi_rresp     (s_axi_rresp),
        .s_axi_rvalid    (s_axi_rvalid),
        .s_axi_rready    (s_axi_rready),
        .reg0_out        (),
        .reg1_out        (),
        .reg2_out        (),
        .reg3_out        (),
        .reg1_status_in  (status_flags),
        .reg1_status_load(1'b1)
    );

endmodule
