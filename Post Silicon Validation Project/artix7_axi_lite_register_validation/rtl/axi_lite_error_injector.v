// axi_lite_error_injector.v
// Sits inline on the AXI-Lite slave port between the interconnect and a
// register block (or between master and interconnect) to deliberately
// inject faults on command from the host. This proves the validation
// framework's negative-test paths (illegal access, protocol violations,
// timeouts) actually get exercised, instead of only ever seeing clean traffic.
//
// Injection is controlled by a small control register written over the same
// command path as everything else (mapped by the parent design at a
// dedicated address region, e.g. 0x300).
//
//   INJECT_CTRL bit 0: force DECERR on next write response
//   INJECT_CTRL bit 1: force SLVERR on next read response
//   INJECT_CTRL bit 2: hold READY low for EXTRA_WAIT_CYCLES on next AW
//                       (to exercise the master's timeout path)
//   INJECT_CTRL bit 3: corrupt RDATA on next read (flips all bits)

`include "axi_lite_pkg_defs.vh"

module axi_lite_error_injector #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter EXTRA_WAIT_CYCLES = 64
) (
    input  wire                      clk,
    input  wire                      rst_n,

    // Control register interface (simple, not full AXI - driven by top level
    // decode of a dedicated small address window)
    input  wire [3:0]                inject_ctrl,
    input  wire                      inject_ctrl_wr,

    // ---------------- Upstream (interconnect-facing) slave port ----------------
    input  wire [ADDR_WIDTH-1:0]     up_awaddr,
    input  wire                      up_awvalid,
    output wire                      up_awready,
    input  wire [DATA_WIDTH-1:0]     up_wdata,
    input  wire [(DATA_WIDTH/8)-1:0] up_wstrb,
    input  wire                      up_wvalid,
    output wire                      up_wready,
    output reg  [1:0]                up_bresp,
    output reg                       up_bvalid,
    input  wire                      up_bready,
    input  wire [ADDR_WIDTH-1:0]     up_araddr,
    input  wire                      up_arvalid,
    output wire                      up_arready,
    output reg  [DATA_WIDTH-1:0]     up_rdata,
    output reg  [1:0]                up_rresp,
    output reg                       up_rvalid,
    input  wire                      up_rready,

    // ---------------- Downstream (register-block-facing) master port ----------------
    output wire [ADDR_WIDTH-1:0]     dn_awaddr,
    output wire                      dn_awvalid,
    input  wire                      dn_awready,
    output wire [DATA_WIDTH-1:0]     dn_wdata,
    output wire [(DATA_WIDTH/8)-1:0] dn_wstrb,
    output wire                      dn_wvalid,
    input  wire                      dn_wready,
    input  wire [1:0]                dn_bresp,
    input  wire                      dn_bvalid,
    output wire                      dn_bready,
    output reg  [ADDR_WIDTH-1:0]     dn_araddr,
    output reg                       dn_arvalid,
    input  wire                      dn_arready,
    input  wire [DATA_WIDTH-1:0]     dn_rdata,
    input  wire [1:0]                dn_rresp,
    input  wire                      dn_rvalid,
    output wire                      dn_rready
);

    reg [3:0]  latched_ctrl;
    reg        force_decerr_w;
    reg        force_slverr_r;
    reg        hold_aw;
    reg        corrupt_rdata;
    reg [7:0]  hold_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            latched_ctrl   <= 4'b0000;
            force_decerr_w <= 1'b0;
            force_slverr_r <= 1'b0;
            hold_aw        <= 1'b0;
            corrupt_rdata  <= 1'b0;
            hold_count     <= 8'd0;
        end else begin
            if (inject_ctrl_wr) begin
                latched_ctrl   <= inject_ctrl;
                force_decerr_w <= inject_ctrl[0];
                force_slverr_r <= inject_ctrl[1];
                hold_aw        <= inject_ctrl[2];
                corrupt_rdata  <= inject_ctrl[3];
                hold_count     <= 8'd0;
            end

            // consume the one-shot injections once they've been applied
            if (force_decerr_w && up_bvalid && up_bready) force_decerr_w <= 1'b0;
            if (force_slverr_r && up_rvalid && up_rready)  force_slverr_r <= 1'b0;
            if (corrupt_rdata  && up_rvalid && up_rready)  corrupt_rdata  <= 1'b0;

            if (hold_aw) begin
                if (hold_count == EXTRA_WAIT_CYCLES) begin
                    hold_aw    <= 1'b0;
                    hold_count <= 8'd0;
                end else begin
                    hold_count <= hold_count + 1'b1;
                end
            end
        end
    end

    // ---------------- Write path passthrough (with optional hold + DECERR) ----------------
    assign dn_awaddr  = up_awaddr;
    assign dn_awvalid = up_awvalid && !hold_aw;
    assign up_awready = hold_aw ? 1'b0 : dn_awready;

    assign dn_wdata  = up_wdata;
    assign dn_wstrb  = up_wstrb;
    assign dn_wvalid = up_wvalid;
    assign up_wready = dn_wready;

    assign dn_bready = up_bready;

    always @(*) begin
        if (force_decerr_w) begin
            up_bvalid = dn_bvalid | up_bready; // ensure a response is produced even without downstream traffic
            up_bresp  = `AXI_RESP_DECERR;
        end else begin
            up_bvalid = dn_bvalid;
            up_bresp  = dn_bresp;
        end
    end

    // ---------------- Read path passthrough (with optional corruption + SLVERR) ----------------
    always @(*) begin
        dn_araddr  = up_araddr;
        dn_arvalid = up_arvalid;
    end
    assign up_arready = dn_arready;
    assign dn_rready  = up_rready;

    always @(*) begin
        if (force_slverr_r) begin
            up_rvalid = dn_rvalid | up_rready;
            up_rresp  = `AXI_RESP_SLVERR;
            up_rdata  = {DATA_WIDTH{1'b0}};
        end else if (corrupt_rdata) begin
            up_rvalid = dn_rvalid;
            up_rresp  = dn_rresp;
            up_rdata  = ~dn_rdata; // flip every bit to simulate data corruption
        end else begin
            up_rvalid = dn_rvalid;
            up_rresp  = dn_rresp;
            up_rdata  = dn_rdata;
        end
    end

endmodule
