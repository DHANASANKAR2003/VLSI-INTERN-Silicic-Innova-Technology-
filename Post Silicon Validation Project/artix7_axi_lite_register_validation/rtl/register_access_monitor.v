// register_access_monitor.v
// Passive monitor that tracks bus activity for coverage purposes:
//   - total write transactions completed
//   - total read transactions completed
//   - total error responses seen (SLVERR or DECERR) on either channel
//   - a small history of the last N accessed addresses, exposed so the
//     host-side coverage_collector.py can sample it via the debug_addr_hist
//     output (wired to a debug/coverage register window by the top level,
//     or read out over a dedicated low-speed serial-debug path).
//
// This module never drives the bus - it only watches.

`include "axi_lite_pkg_defs.vh"

module register_access_monitor #(
    parameter ADDR_WIDTH  = 32,
    parameter HIST_DEPTH  = 8
) (
    input  wire                  clk,
    input  wire                  rst_n,

    input  wire [ADDR_WIDTH-1:0] awaddr,
    input  wire                  awvalid,
    input  wire                  awready,

    input  wire                  bvalid,
    input  wire                  bready,
    input  wire [1:0]            bresp,

    input  wire [ADDR_WIDTH-1:0] araddr,
    input  wire                  arvalid,
    input  wire                  arready,

    input  wire                  rvalid,
    input  wire                  rready,
    input  wire [1:0]            rresp,

    output reg  [31:0]           write_count,
    output reg  [31:0]           read_count,
    output reg  [31:0]           error_count,
    output reg  [ADDR_WIDTH-1:0] last_addr_accessed,
    output reg  [ADDR_WIDTH-1:0] debug_addr_hist [0:HIST_DEPTH-1]
);

    integer i;
    wire write_accepted = awvalid && awready;
    wire read_accepted  = arvalid && arready;
    wire write_done     = bvalid && bready;
    wire read_done       = rvalid && rready;
    wire write_err       = write_done && (bresp == `AXI_RESP_SLVERR || bresp == `AXI_RESP_DECERR);
    wire read_err        = read_done  && (rresp == `AXI_RESP_SLVERR || rresp == `AXI_RESP_DECERR);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_count        <= 32'd0;
            read_count         <= 32'd0;
            error_count        <= 32'd0;
            last_addr_accessed <= {ADDR_WIDTH{1'b0}};
            for (i = 0; i < HIST_DEPTH; i = i + 1) begin
                debug_addr_hist[i] <= {ADDR_WIDTH{1'b0}};
            end
        end else begin
            if (write_done) begin
                write_count <= write_count + 1'b1;
            end
            if (read_done) begin
                read_count <= read_count + 1'b1;
            end
            if (write_err || read_err) begin
                error_count <= error_count + 1'b1;
            end

            if (write_accepted) begin
                last_addr_accessed <= awaddr;
                for (i = HIST_DEPTH - 1; i > 0; i = i - 1) begin
                    debug_addr_hist[i] <= debug_addr_hist[i-1];
                end
                debug_addr_hist[0] <= awaddr;
            end else if (read_accepted) begin
                last_addr_accessed <= araddr;
                for (i = HIST_DEPTH - 1; i > 0; i = i - 1) begin
                    debug_addr_hist[i] <= debug_addr_hist[i-1];
                end
                debug_addr_hist[0] <= araddr;
            end
        end
    end

endmodule
