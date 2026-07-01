// axi_lite_protocol_checker.v
// Passive bus monitor (does not sit in the data path - just observes).
// Checks the AXI-Lite VALID/READY handshake rules on all 5 channels:
//   1. Once VALID is asserted, it must stay asserted until READY arrives
//      (a master/slave is not allowed to "take back" a pending transfer).
//   2. (Soft check) flags if a channel's VALID has been asserted for longer
//      than STALL_LIMIT cycles without READY - a possible stuck-bus condition,
//      useful context alongside the master's own hard timeout.
//
// All violations are latched (sticky) until reset, and also pulse for one
// cycle so external coverage/logging logic can count distinct events.

module axi_lite_protocol_checker #(
    parameter STALL_LIMIT = 256
) (
    input  wire clk,
    input  wire rst_n,

    // Observed signals - tap these directly off the bus, read-only
    input  wire awvalid, input  wire awready,
    input  wire wvalid,  input  wire wready,
    input  wire bvalid,  input  wire bready,
    input  wire arvalid, input  wire arready,
    input  wire rvalid,  input  wire rready,

    output reg  violation_pulse,   // 1-cycle pulse on any new violation
    output reg  violation_latched, // sticky until reset
    output reg  stall_warning      // a channel has been stalled past STALL_LIMIT
);

    // Per-channel "was VALID asserted last cycle without being accepted" trackers
    reg aw_prev_valid, w_prev_valid, b_prev_valid, ar_prev_valid, r_prev_valid;
    reg [15:0] aw_stall_cnt, ar_stall_cnt;
    reg aw_viol, w_viol, b_viol, ar_viol, r_viol;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            aw_prev_valid     <= 1'b0;
            w_prev_valid      <= 1'b0;
            b_prev_valid      <= 1'b0;
            ar_prev_valid     <= 1'b0;
            r_prev_valid      <= 1'b0;
            aw_stall_cnt      <= 16'd0;
            ar_stall_cnt      <= 16'd0;
            aw_viol           <= 1'b0;
            w_viol            <= 1'b0;
            b_viol            <= 1'b0;
            ar_viol           <= 1'b0;
            r_viol            <= 1'b0;
            violation_pulse   <= 1'b0;
            violation_latched <= 1'b0;
            stall_warning     <= 1'b0;
        end else begin
            // Rule: if VALID was high last cycle and the transfer did not
            // complete (READY wasn't high), VALID must still be high now.
            aw_viol <= aw_prev_valid && !awvalid_completed_last_cycle(aw_prev_valid, awready) && !awvalid;
            w_viol  <= w_prev_valid  && !w_completed_last_cycle(w_prev_valid, wready)         && !wvalid;
            b_viol  <= b_prev_valid  && !b_completed_last_cycle(b_prev_valid, bready)         && !bvalid;
            ar_viol <= ar_prev_valid && !ar_completed_last_cycle(ar_prev_valid, arready)      && !arvalid;
            r_viol  <= r_prev_valid  && !r_completed_last_cycle(r_prev_valid, rready)         && !rvalid;

            aw_prev_valid <= awvalid && !(awvalid && awready); // remains "pending" unless accepted this cycle
            w_prev_valid  <= wvalid  && !(wvalid  && wready);
            b_prev_valid  <= bvalid  && !(bvalid  && bready);
            ar_prev_valid <= arvalid && !(arvalid && arready);
            r_prev_valid  <= rvalid  && !(rvalid  && rready);

            violation_pulse <= aw_viol || w_viol || b_viol || ar_viol || r_viol;
            if (aw_viol || w_viol || b_viol || ar_viol || r_viol) begin
                violation_latched <= 1'b1;
            end

            // Stall warnings (soft, informational)
            if (awvalid && !awready) begin
                aw_stall_cnt <= aw_stall_cnt + 1'b1;
            end else begin
                aw_stall_cnt <= 16'd0;
            end

            if (arvalid && !arready) begin
                ar_stall_cnt <= ar_stall_cnt + 1'b1;
            end else begin
                ar_stall_cnt <= 16'd0;
            end

            stall_warning <= (aw_stall_cnt >= STALL_LIMIT) || (ar_stall_cnt >= STALL_LIMIT);
        end
    end

    // Helper functions: "did this channel complete its transfer using the
    // VALID state captured one cycle ago, given current READY?" These exist
    // purely to make the always-block logic above readable.
    function awvalid_completed_last_cycle(input was_pending, input ready_now);
        awvalid_completed_last_cycle = was_pending && ready_now;
    endfunction
    function w_completed_last_cycle(input was_pending, input ready_now);
        w_completed_last_cycle = was_pending && ready_now;
    endfunction
    function b_completed_last_cycle(input was_pending, input ready_now);
        b_completed_last_cycle = was_pending && ready_now;
    endfunction
    function ar_completed_last_cycle(input was_pending, input ready_now);
        ar_completed_last_cycle = was_pending && ready_now;
    endfunction
    function r_completed_last_cycle(input was_pending, input ready_now);
        r_completed_last_cycle = was_pending && ready_now;
    endfunction

endmodule
