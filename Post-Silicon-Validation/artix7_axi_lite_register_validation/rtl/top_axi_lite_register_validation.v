// top_axi_lite_register_validation.v
// Top-level design for the artix7_axi_lite_register_validation project.
// Ties together: UART RX/TX -> uart_register_interface -> AXI-Lite master
// cmd if -> error injector -> interconnect -> {gpio, status, timer} regs,
// with the protocol checker, register access monitor, and reset recovery
// monitor all observing the bus passively.
//
// This is the single file that gets added as the top module in Vivado and
// synthesized into the bitstream programmed onto the EDGE Artix-7 board.

`include "axi_lite_pkg_defs.vh"

module top_axi_lite_register_validation #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115_200
) (
    input  wire clk,        // board system clock
    input  wire rst_n_pin,  // active-low reset, e.g. a push button
    input  wire uart_rx_pin,
    output wire uart_tx_pin,

    // Optional physical GPIO pins wired straight through to the GPIO bank,
    // exposing real board switches/LEDs to AXI-Lite register tests.
    output wire [15:0] led_pins,
    input  wire [15:0] switch_pins
);

    wire rst_n = ~rst_n_pin;

    // ---------------- UART RX/TX ----------------
    wire [7:0] rx_data;
    wire       rx_valid;
    wire       rx_error;

    wire [7:0] tx_data;
    wire       tx_start;
    wire       tx_busy;

    uart_rx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_uart_rx (
        .clk     (clk),
        .rst_n   (rst_n),
        .rx      (uart_rx_pin),
        .rx_data (rx_data),
        .rx_valid(rx_valid),
        .rx_error(rx_error)
    );

    uart_tx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_uart_tx (
        .clk     (clk),
        .rst_n   (rst_n),
        .tx_data (tx_data),
        .tx_start(tx_start),
        .tx      (uart_tx_pin),
        .tx_busy (tx_busy)
    );

    // ---------------- UART register interface ----------------
    wire [31:0] cmd_addr;
    wire [31:0] cmd_wdata;
    wire        cmd_is_write;
    wire        cmd_valid;
    wire        cmd_ready;

    wire [31:0] resp_rdata;
    wire [1:0]  resp_axi_status;
    wire        resp_valid;
    wire        resp_ack;

    uart_register_interface u_uart_reg_if (
        .clk         (clk),
        .rst_n       (rst_n),
        .rx_data     (rx_data),
        .rx_valid    (rx_valid),
        .tx_data     (tx_data),
        .tx_start    (tx_start),
        .tx_busy     (tx_busy),
        .cmd_addr    (cmd_addr),
        .cmd_wdata   (cmd_wdata),
        .cmd_is_write(cmd_is_write),
        .cmd_valid   (cmd_valid),
        .cmd_ready   (cmd_ready),
        .resp_rdata     (resp_rdata),
        .resp_axi_status(resp_axi_status),
        .resp_valid     (resp_valid),
        .resp_ack       (resp_ack)
    );

    // ---------------- AXI-Lite master ----------------
    wire [31:0] m_awaddr,  m_wdata,  m_araddr;
    wire [3:0]  m_wstrb;
    wire        m_awvalid, m_awready;
    wire        m_wvalid,  m_wready;
    wire [1:0]  m_bresp;
    wire        m_bvalid,  m_bready;
    wire        m_arvalid, m_arready;
    wire [31:0] m_rdata;
    wire [1:0]  m_rresp;
    wire        m_rvalid,  m_rready;
    wire        master_timeout_error;

    axi_lite_master_cmd_if u_master (
        .clk          (clk),
        .rst_n        (rst_n),
        .cmd_addr     (cmd_addr),
        .cmd_wdata    (cmd_wdata),
        .cmd_is_write (cmd_is_write),
        .cmd_valid    (cmd_valid),
        .cmd_ready    (cmd_ready),
        .resp_rdata     (resp_rdata),
        .resp_axi_status(resp_axi_status),
        .resp_valid     (resp_valid),
        .resp_ack       (resp_ack),
        .m_axi_awaddr (m_awaddr),  .m_axi_awvalid(m_awvalid), .m_axi_awready(m_awready),
        .m_axi_wdata  (m_wdata),   .m_axi_wstrb  (m_wstrb),
        .m_axi_wvalid (m_wvalid),  .m_axi_wready (m_wready),
        .m_axi_bresp  (m_bresp),   .m_axi_bvalid (m_bvalid),  .m_axi_bready (m_bready),
        .m_axi_araddr (m_araddr),  .m_axi_arvalid(m_arvalid), .m_axi_arready(m_arready),
        .m_axi_rdata  (m_rdata),   .m_axi_rresp  (m_rresp),
        .m_axi_rvalid (m_rvalid),  .m_axi_rready (m_rready),
        .timeout_error(master_timeout_error)
    );

    // ---------------- Error injector (inline, master-facing side) ----------------
    // Tied to "no injection" by default for normal bring-up; a fuller build
    // can drive inject_ctrl from a dedicated debug register.
    wire [31:0] ei_awaddr, ei_wdata, ei_araddr, ei_rdata;
    wire [3:0]  ei_wstrb;
    wire        ei_awvalid, ei_awready, ei_wvalid, ei_wready;
    wire [1:0]  ei_bresp, ei_rresp;
    wire        ei_bvalid, ei_bready;
    wire        ei_arvalid, ei_arready, ei_rvalid, ei_rready;

    axi_lite_error_injector u_error_injector (
        .clk            (clk),
        .rst_n          (rst_n),
        .inject_ctrl    (4'b0000),
        .inject_ctrl_wr (1'b0),
        .up_awaddr (m_awaddr),  .up_awvalid(m_awvalid), .up_awready(m_awready),
        .up_wdata  (m_wdata),   .up_wstrb  (m_wstrb),
        .up_wvalid (m_wvalid),  .up_wready (m_wready),
        .up_bresp  (m_bresp),   .up_bvalid (m_bvalid),  .up_bready (m_bready),
        .up_araddr (m_araddr),  .up_arvalid(m_arvalid), .up_arready(m_arready),
        .up_rdata  (m_rdata),   .up_rresp  (m_rresp),
        .up_rvalid (m_rvalid),  .up_rready (m_rready),
        .dn_awaddr (ei_awaddr), .dn_awvalid(ei_awvalid), .dn_awready(ei_awready),
        .dn_wdata  (ei_wdata),  .dn_wstrb  (ei_wstrb),
        .dn_wvalid (ei_wvalid), .dn_wready (ei_wready),
        .dn_bresp  (ei_bresp),  .dn_bvalid (ei_bvalid),  .dn_bready (ei_bready),
        .dn_araddr (ei_araddr), .dn_arvalid(ei_arvalid), .dn_arready(ei_arready),
        .dn_rdata  (ei_rdata),  .dn_rresp  (ei_rresp),
        .dn_rvalid (ei_rvalid), .dn_rready (ei_rready)
    );

    // ---------------- Interconnect ----------------
    wire [31:0] g_awaddr, g_wdata, g_araddr, g_rdata;
    wire [3:0]  g_wstrb;
    wire        g_awvalid, g_awready, g_wvalid, g_wready;
    wire [1:0]  g_bresp, g_rresp;
    wire        g_bvalid, g_bready, g_arvalid, g_arready, g_rvalid, g_rready;

    wire [31:0] s_awaddr, s_wdata, s_araddr, s_rdata;
    wire [3:0]  s_wstrb;
    wire        s_awvalid, s_awready, s_wvalid, s_wready;
    wire [1:0]  s_bresp, s_rresp;
    wire        s_bvalid, s_bready, s_arvalid, s_arready, s_rvalid, s_rready;

    wire [31:0] t_awaddr, t_wdata, t_araddr, t_rdata;
    wire [3:0]  t_wstrb;
    wire        t_awvalid, t_awready, t_wvalid, t_wready;
    wire [1:0]  t_bresp, t_rresp;
    wire        t_bvalid, t_bready, t_arvalid, t_arready, t_rvalid, t_rready;

    wire decode_error;

    axi_lite_interconnect u_interconnect (
        .clk  (clk), .rst_n(rst_n),
        .s_axi_awaddr (ei_awaddr), .s_axi_awvalid(ei_awvalid), .s_axi_awready(ei_awready),
        .s_axi_wdata  (ei_wdata),  .s_axi_wstrb  (ei_wstrb),
        .s_axi_wvalid (ei_wvalid), .s_axi_wready (ei_wready),
        .s_axi_bresp  (ei_bresp),  .s_axi_bvalid (ei_bvalid),  .s_axi_bready (ei_bready),
        .s_axi_araddr (ei_araddr), .s_axi_arvalid(ei_arvalid), .s_axi_arready(ei_arready),
        .s_axi_rdata  (ei_rdata),  .s_axi_rresp  (ei_rresp),
        .s_axi_rvalid (ei_rvalid), .s_axi_rready (ei_rready),

        .m0_axi_awaddr(g_awaddr), .m0_axi_awvalid(g_awvalid), .m0_axi_awready(g_awready),
        .m0_axi_wdata (g_wdata),  .m0_axi_wstrb  (g_wstrb),
        .m0_axi_wvalid(g_wvalid), .m0_axi_wready (g_wready),
        .m0_axi_bresp (g_bresp),  .m0_axi_bvalid (g_bvalid),  .m0_axi_bready (g_bready),
        .m0_axi_araddr(g_araddr), .m0_axi_arvalid(g_arvalid), .m0_axi_arready(g_arready),
        .m0_axi_rdata (g_rdata),  .m0_axi_rresp  (g_rresp),
        .m0_axi_rvalid(g_rvalid), .m0_axi_rready (g_rready),

        .m1_axi_awaddr(s_awaddr), .m1_axi_awvalid(s_awvalid), .m1_axi_awready(s_awready),
        .m1_axi_wdata (s_wdata),  .m1_axi_wstrb  (s_wstrb),
        .m1_axi_wvalid(s_wvalid), .m1_axi_wready (s_wready),
        .m1_axi_bresp (s_bresp),  .m1_axi_bvalid (s_bvalid),  .m1_axi_bready (s_bready),
        .m1_axi_araddr(s_araddr), .m1_axi_arvalid(s_arvalid), .m1_axi_arready(s_arready),
        .m1_axi_rdata (s_rdata),  .m1_axi_rresp  (s_rresp),
        .m1_axi_rvalid(s_rvalid), .m1_axi_rready (s_rready),

        .m2_axi_awaddr(t_awaddr), .m2_axi_awvalid(t_awvalid), .m2_axi_awready(t_awready),
        .m2_axi_wdata (t_wdata),  .m2_axi_wstrb  (t_wstrb),
        .m2_axi_wvalid(t_wvalid), .m2_axi_wready (t_wready),
        .m2_axi_bresp (t_bresp),  .m2_axi_bvalid (t_bvalid),  .m2_axi_bready (t_bready),
        .m2_axi_araddr(t_araddr), .m2_axi_arvalid(t_arvalid), .m2_axi_arready(t_arready),
        .m2_axi_rdata (t_rdata),  .m2_axi_rresp  (t_rresp),
        .m2_axi_rvalid(t_rvalid), .m2_axi_rready (t_rready),

        .decode_error(decode_error)
    );

    // ---------------- Register blocks ----------------
    wire timer_expired;
    wire protocol_violation, protocol_violation_latched, stall_warning;
    wire reset_in_progress;

    wire [31:0] gpio_out_pins_32;
    assign led_pins = gpio_out_pins_32[15:0];

    axi_lite_gpio_regs u_gpio (
        .clk(clk), .rst_n(rst_n),
        .s_axi_awaddr(g_awaddr), .s_axi_awvalid(g_awvalid), .s_axi_awready(g_awready),
        .s_axi_wdata (g_wdata),  .s_axi_wstrb  (g_wstrb),
        .s_axi_wvalid(g_wvalid), .s_axi_wready (g_wready),
        .s_axi_bresp (g_bresp),  .s_axi_bvalid (g_bvalid),  .s_axi_bready(g_bready),
        .s_axi_araddr(g_araddr), .s_axi_arvalid(g_arvalid), .s_axi_arready(g_arready),
        .s_axi_rdata (g_rdata),  .s_axi_rresp  (g_rresp),
        .s_axi_rvalid(g_rvalid), .s_axi_rready (g_rready),
        .gpio_out_pins(gpio_out_pins_32),
        .gpio_in_pins ({16'd0, switch_pins})
    );

    axi_lite_status_regs u_status (
        .clk(clk), .rst_n(rst_n),
        .s_axi_awaddr(s_awaddr), .s_axi_awvalid(s_awvalid), .s_axi_awready(s_awready),
        .s_axi_wdata (s_wdata),  .s_axi_wstrb  (s_wstrb),
        .s_axi_wvalid(s_wvalid), .s_axi_wready (s_wready),
        .s_axi_bresp (s_bresp),  .s_axi_bvalid (s_bvalid),  .s_axi_bready(s_bready),
        .s_axi_araddr(s_araddr), .s_axi_arvalid(s_arvalid), .s_axi_arready(s_arready),
        .s_axi_rdata (s_rdata),  .s_axi_rresp  (s_rresp),
        .s_axi_rvalid(s_rvalid), .s_axi_rready (s_rready),
        .protocol_error_in     (protocol_violation_latched),
        .decode_error_in       (decode_error),
        .timeout_error_in      (master_timeout_error),
        .reset_in_progress_in  (reset_in_progress)
    );

    axi_lite_timer_regs u_timer (
        .clk(clk), .rst_n(rst_n),
        .s_axi_awaddr(t_awaddr), .s_axi_awvalid(t_awvalid), .s_axi_awready(t_awready),
        .s_axi_wdata (t_wdata),  .s_axi_wstrb  (t_wstrb),
        .s_axi_wvalid(t_wvalid), .s_axi_wready (t_wready),
        .s_axi_bresp (t_bresp),  .s_axi_bvalid (t_bvalid),  .s_axi_bready(t_bready),
        .s_axi_araddr(t_araddr), .s_axi_arvalid(t_arvalid), .s_axi_arready(t_arready),
        .s_axi_rdata (t_rdata),  .s_axi_rresp  (t_rresp),
        .s_axi_rvalid(t_rvalid), .s_axi_rready (t_rready),
        .timer_expired_pulse(timer_expired)
    );

    // ---------------- Passive monitors ----------------
    axi_lite_protocol_checker u_protocol_checker (
        .clk(clk), .rst_n(rst_n),
        .awvalid(m_awvalid), .awready(m_awready),
        .wvalid (m_wvalid),  .wready (m_wready),
        .bvalid (m_bvalid),  .bready (m_bready),
        .arvalid(m_arvalid), .arready(m_arready),
        .rvalid (m_rvalid),  .rready (m_rready),
        .violation_pulse  (protocol_violation),
        .violation_latched(protocol_violation_latched),
        .stall_warning    (stall_warning)
    );

    wire [31:0] write_count, read_count, error_count, last_addr;
    register_access_monitor u_access_monitor (
        .clk(clk), .rst_n(rst_n),
        .awaddr(m_awaddr), .awvalid(m_awvalid), .awready(m_awready),
        .bvalid(m_bvalid), .bready(m_bready), .bresp(m_bresp),
        .araddr(m_araddr), .arvalid(m_arvalid), .arready(m_arready),
        .rvalid(m_rvalid), .rready(m_rready), .rresp(m_rresp),
        .write_count(write_count),
        .read_count (read_count),
        .error_count(error_count),
        .last_addr_accessed(last_addr)
    );

    reset_recovery_monitor u_reset_monitor (
        .clk(clk), .rst_n(rst_n),
        .bus_activity(m_awvalid || m_arvalid),
        .reset_in_progress     (reset_in_progress),
        .reset_count           (),
        .premature_access_flag ()
    );

endmodule
