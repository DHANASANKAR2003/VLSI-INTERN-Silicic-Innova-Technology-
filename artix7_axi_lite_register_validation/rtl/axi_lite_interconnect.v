// axi_lite_interconnect.v
// AXI-Lite interconnect + address decoder, combined into one module.
// Sits between the single AXI-Lite master (axi_lite_master_cmd_if) and the
// three slave register blocks (GPIO, status, timer). Decodes the incoming
// address to select exactly one slave; if no slave matches, returns DECERR
// directly without ever asserting any slave's valid signals.
//
// Address map (byte addresses, each region 0x100 = 256 bytes):
//   0x0000_0000 - 0x0000_00FF : GPIO regs    (axi_lite_gpio_regs)
//   0x0000_0100 - 0x0000_01FF : Status regs  (axi_lite_status_regs)
//   0x0000_0200 - 0x0000_02FF : Timer regs   (axi_lite_timer_regs)
//   anything else             : DECERR

`include "axi_lite_pkg_defs.vh"

module axi_lite_interconnect #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input  wire                      clk,
    input  wire                      rst_n,

    // ---------------- Slave port (from master) ----------------
    input  wire [ADDR_WIDTH-1:0]     s_axi_awaddr,
    input  wire                      s_axi_awvalid,
    output wire                      s_axi_awready,

    input  wire [DATA_WIDTH-1:0]     s_axi_wdata,
    input  wire [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input  wire                      s_axi_wvalid,
    output wire                      s_axi_wready,

    output reg  [1:0]                s_axi_bresp,
    output reg                       s_axi_bvalid,
    input  wire                      s_axi_bready,

    input  wire [ADDR_WIDTH-1:0]     s_axi_araddr,
    input  wire                      s_axi_arvalid,
    output wire                      s_axi_arready,

    output reg  [DATA_WIDTH-1:0]     s_axi_rdata,
    output reg  [1:0]                s_axi_rresp,
    output reg                       s_axi_rvalid,
    input  wire                      s_axi_rready,

    // ---------------- Master port 0: GPIO regs ----------------
    output wire [ADDR_WIDTH-1:0]     m0_axi_awaddr,
    output wire                      m0_axi_awvalid,
    input  wire                      m0_axi_awready,
    output wire [DATA_WIDTH-1:0]     m0_axi_wdata,
    output wire [(DATA_WIDTH/8)-1:0] m0_axi_wstrb,
    output wire                      m0_axi_wvalid,
    input  wire                      m0_axi_wready,
    input  wire [1:0]                m0_axi_bresp,
    input  wire                      m0_axi_bvalid,
    output wire                      m0_axi_bready,
    output wire [ADDR_WIDTH-1:0]     m0_axi_araddr,
    output wire                      m0_axi_arvalid,
    input  wire                      m0_axi_arready,
    input  wire [DATA_WIDTH-1:0]     m0_axi_rdata,
    input  wire [1:0]                m0_axi_rresp,
    input  wire                      m0_axi_rvalid,
    output wire                      m0_axi_rready,

    // ---------------- Master port 1: Status regs ----------------
    output wire [ADDR_WIDTH-1:0]     m1_axi_awaddr,
    output wire                      m1_axi_awvalid,
    input  wire                      m1_axi_awready,
    output wire [DATA_WIDTH-1:0]     m1_axi_wdata,
    output wire [(DATA_WIDTH/8)-1:0] m1_axi_wstrb,
    output wire                      m1_axi_wvalid,
    input  wire                      m1_axi_wready,
    input  wire [1:0]                m1_axi_bresp,
    input  wire                      m1_axi_bvalid,
    output wire                      m1_axi_bready,
    output wire [ADDR_WIDTH-1:0]     m1_axi_araddr,
    output wire                      m1_axi_arvalid,
    input  wire                      m1_axi_arready,
    input  wire [DATA_WIDTH-1:0]     m1_axi_rdata,
    input  wire [1:0]                m1_axi_rresp,
    input  wire                      m1_axi_rvalid,
    output wire                      m1_axi_rready,

    // ---------------- Master port 2: Timer regs ----------------
    output wire [ADDR_WIDTH-1:0]     m2_axi_awaddr,
    output wire                      m2_axi_awvalid,
    input  wire                      m2_axi_awready,
    output wire [DATA_WIDTH-1:0]     m2_axi_wdata,
    output wire [(DATA_WIDTH/8)-1:0] m2_axi_wstrb,
    output wire                      m2_axi_wvalid,
    input  wire                      m2_axi_wready,
    input  wire [1:0]                m2_axi_bresp,
    input  wire                      m2_axi_bvalid,
    output wire                      m2_axi_bready,
    output wire [ADDR_WIDTH-1:0]     m2_axi_araddr,
    output wire                      m2_axi_arvalid,
    input  wire                      m2_axi_arready,
    input  wire [DATA_WIDTH-1:0]     m2_axi_rdata,
    input  wire [1:0]                m2_axi_rresp,
    input  wire                      m2_axi_rvalid,
    output wire                      m2_axi_rready,

    // Decode error flag, useful for the protocol checker / coverage
    output reg                       decode_error
);

    localparam [ADDR_WIDTH-1:0] GPIO_BASE   = 32'h0000_0000;
    localparam [ADDR_WIDTH-1:0] GPIO_LIMIT  = 32'h0000_00FF;
    localparam [ADDR_WIDTH-1:0] STATUS_BASE = 32'h0000_0100;
    localparam [ADDR_WIDTH-1:0] STATUS_LIMIT= 32'h0000_01FF;
    localparam [ADDR_WIDTH-1:0] TIMER_BASE  = 32'h0000_0200;
    localparam [ADDR_WIDTH-1:0] TIMER_LIMIT = 32'h0000_02FF;

    // ---------------- Write-address decode ----------------
    wire aw_sel_gpio   = (s_axi_awaddr >= GPIO_BASE)   && (s_axi_awaddr <= GPIO_LIMIT);
    wire aw_sel_status = (s_axi_awaddr >= STATUS_BASE) && (s_axi_awaddr <= STATUS_LIMIT);
    wire aw_sel_timer  = (s_axi_awaddr >= TIMER_BASE)  && (s_axi_awaddr <= TIMER_LIMIT);
    wire aw_sel_none   = !(aw_sel_gpio || aw_sel_status || aw_sel_timer);

    // ---------------- Read-address decode ----------------
    wire ar_sel_gpio   = (s_axi_araddr >= GPIO_BASE)   && (s_axi_araddr <= GPIO_LIMIT);
    wire ar_sel_status = (s_axi_araddr >= STATUS_BASE) && (s_axi_araddr <= STATUS_LIMIT);
    wire ar_sel_timer  = (s_axi_araddr >= TIMER_BASE)  && (s_axi_araddr <= TIMER_LIMIT);
    wire ar_sel_none   = !(ar_sel_gpio || ar_sel_status || ar_sel_timer);

    // ---------------- Write address/data fan-out ----------------
    assign m0_axi_awaddr = s_axi_awaddr;
    assign m1_axi_awaddr = s_axi_awaddr;
    assign m2_axi_awaddr = s_axi_awaddr;

    assign m0_axi_awvalid = s_axi_awvalid && aw_sel_gpio;
    assign m1_axi_awvalid = s_axi_awvalid && aw_sel_status;
    assign m2_axi_awvalid = s_axi_awvalid && aw_sel_timer;

    assign m0_axi_wdata = s_axi_wdata;
    assign m1_axi_wdata = s_axi_wdata;
    assign m2_axi_wdata = s_axi_wdata;
    assign m0_axi_wstrb = s_axi_wstrb;
    assign m1_axi_wstrb = s_axi_wstrb;
    assign m2_axi_wstrb = s_axi_wstrb;

    assign m0_axi_wvalid = s_axi_wvalid && aw_sel_gpio;
    assign m1_axi_wvalid = s_axi_wvalid && aw_sel_status;
    assign m2_axi_wvalid = s_axi_wvalid && aw_sel_timer;

    assign s_axi_awready = aw_sel_gpio   ? m0_axi_awready :
                            aw_sel_status ? m1_axi_awready :
                            aw_sel_timer  ? m2_axi_awready :
                            1'b1; // unmapped address: accept immediately, will DECERR

    assign s_axi_wready  = aw_sel_gpio   ? m0_axi_wready :
                            aw_sel_status ? m1_axi_wready :
                            aw_sel_timer  ? m2_axi_wready :
                            1'b1;

    assign m0_axi_bready = s_axi_bready && aw_sel_gpio;
    assign m1_axi_bready = s_axi_bready && aw_sel_status;
    assign m2_axi_bready = s_axi_bready && aw_sel_timer;

    // ---------------- Read address fan-out ----------------
    assign m0_axi_araddr = s_axi_araddr;
    assign m1_axi_araddr = s_axi_araddr;
    assign m2_axi_araddr = s_axi_araddr;

    assign m0_axi_arvalid = s_axi_arvalid && ar_sel_gpio;
    assign m1_axi_arvalid = s_axi_arvalid && ar_sel_status;
    assign m2_axi_arvalid = s_axi_arvalid && ar_sel_timer;

    assign s_axi_arready = ar_sel_gpio   ? m0_axi_arready :
                            ar_sel_status ? m1_axi_arready :
                            ar_sel_timer  ? m2_axi_arready :
                            1'b1;

    assign m0_axi_rready = s_axi_rready && ar_sel_gpio;
    assign m1_axi_rready = s_axi_rready && ar_sel_status;
    assign m2_axi_rready = s_axi_rready && ar_sel_timer;

    // ---------------- DECERR Handshake Generator for Unmapped Addresses ----------------
    reg aw_done_none;
    reg w_done_none;
    reg bvalid_none;
    reg rvalid_none;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            aw_done_none <= 1'b0;
            w_done_none  <= 1'b0;
            bvalid_none  <= 1'b0;
        end else begin
            // Track write address acceptance
            if (s_axi_awvalid && s_axi_awready && aw_sel_none) begin
                aw_done_none <= 1'b1;
            end
            // Track write data acceptance
            if (s_axi_wvalid && s_axi_wready && aw_sel_none) begin
                w_done_none <= 1'b1;
            end

            // Generate bvalid when both address and data have been accepted
            if (((s_axi_awvalid && s_axi_awready && aw_sel_none) || aw_done_none) &&
                ((s_axi_wvalid && s_axi_wready && aw_sel_none) || w_done_none)) begin
                bvalid_none <= 1'b1;
            end

            // Clear everything on write response handshake
            if (s_axi_bvalid && s_axi_bready) begin
                aw_done_none <= 1'b0;
                w_done_none  <= 1'b0;
                bvalid_none  <= 1'b0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rvalid_none <= 1'b0;
        end else begin
            if (s_axi_arvalid && s_axi_arready && ar_sel_none) begin
                rvalid_none <= 1'b1;
            end else if (s_axi_rvalid && s_axi_rready) begin
                rvalid_none <= 1'b0;
            end
        end
    end

    // ---------------- Write response mux (with DECERR injection) ----------------
    always @(*) begin
        if (bvalid_none) begin
            s_axi_bvalid = 1'b1;
            s_axi_bresp  = `AXI_RESP_DECERR;
        end else if (aw_sel_gpio) begin
            s_axi_bvalid = m0_axi_bvalid;
            s_axi_bresp  = m0_axi_bresp;
        end else if (aw_sel_status) begin
            s_axi_bvalid = m1_axi_bvalid;
            s_axi_bresp  = m1_axi_bresp;
        end else if (aw_sel_timer) begin
            s_axi_bvalid = m2_axi_bvalid;
            s_axi_bresp  = m2_axi_bresp;
        end else begin
            s_axi_bvalid = 1'b0;
            s_axi_bresp  = `AXI_RESP_OKAY;
        end
    end

    // ---------------- Read data mux (with DECERR injection) ----------------
    always @(*) begin
        if (rvalid_none) begin
            s_axi_rvalid = 1'b1;
            s_axi_rresp  = `AXI_RESP_DECERR;
            s_axi_rdata  = {DATA_WIDTH{1'b0}};
        end else if (ar_sel_gpio) begin
            s_axi_rvalid = m0_axi_rvalid;
            s_axi_rresp  = m0_axi_rresp;
            s_axi_rdata  = m0_axi_rdata;
        end else if (ar_sel_status) begin
            s_axi_rvalid = m1_axi_rvalid;
            s_axi_rresp  = m1_axi_rresp;
            s_axi_rdata  = m1_axi_rdata;
        end else if (ar_sel_timer) begin
            s_axi_rvalid = m2_axi_rvalid;
            s_axi_rresp  = m2_axi_rresp;
            s_axi_rdata  = m2_axi_rdata;
        end else begin
            s_axi_rvalid = 1'b0;
            s_axi_rresp  = `AXI_RESP_OKAY;
            s_axi_rdata  = {DATA_WIDTH{1'b0}};
        end
    end

    // ---------------- Decode error flag (for coverage/reporting) ----------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            decode_error <= 1'b0;
        end else begin
            decode_error <= (s_axi_awvalid && aw_sel_none) || (s_axi_arvalid && ar_sel_none);
        end
    end

endmodule
