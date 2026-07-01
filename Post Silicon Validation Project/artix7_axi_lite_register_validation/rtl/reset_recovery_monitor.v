// reset_recovery_monitor.v
// Watches the reset line and the bus around a reset event to support
// test_reset_recovery / test_reset_values style checks:
//   - asserts reset_in_progress while rst_n is low and for a short settle
//     window immediately after it goes high, so the status regs can report
//     "do not trust register reads yet" to the host.
//   - counts how many reset pulses have occurred (useful for the host to
//     confirm a reset it issued was actually observed by the FPGA).
//   - flags premature_access_flag if the bus attempts a transaction during
//     the settle window, which the host's test_reset_recovery.py treats as
//     a sequencing bug in the host script itself (it should wait).

module reset_recovery_monitor #(
    parameter SETTLE_CYCLES = 16
) (
    input  wire clk,
    input  wire rst_n,

    // Tap any AXI-Lite valid signal here (e.g. OR of awvalid/arvalid) to
    // detect activity during the settle window.
    input  wire bus_activity,

    output reg        reset_in_progress,
    output reg [31:0] reset_count,
    output reg        premature_access_flag
);

    reg [7:0] settle_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reset_in_progress      <= 1'b1;
            settle_cnt              <= 8'd0;
            premature_access_flag  <= 1'b0;
        end else begin
            if (settle_cnt < SETTLE_CYCLES) begin
                reset_in_progress <= 1'b1;
                settle_cnt         <= settle_cnt + 1'b1;
                if (bus_activity) begin
                    premature_access_flag <= 1'b1;
                end
            end else begin
                reset_in_progress <= 1'b0;
            end
        end
    end

    // Counts reset *edges* (falling edges of rst_n). Initialized once via
    // an initial block since it must persist correctly even though the
    // synchronous logic above runs inside the same reset domain.
    initial begin
        reset_count = 32'd0;
    end

    always @(negedge rst_n) begin
        reset_count <= reset_count + 1'b1;
    end

endmodule
