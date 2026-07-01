// top_adder_subtractor.v
// Top-level FPGA wrapper for the simplified 8-bit Adder/Subtractor project.

module top_adder_subtractor (
    input  wire       clk,          // 50 MHz crystal oscillator
    input  wire       rst_n_pin,    // Center push button on board (active-high reset)
    input  wire       uart_rx_pin,  // UART RX line
    output wire       uart_tx_pin,  // UART TX line
    output wire [7:0] led_pins      // 8 board LEDs to show result
);

    // Active-low internal reset logic (button goes High when pressed)
    wire rst_n = ~rst_n_pin;

    // UART RX signals
    wire [7:0] rx_data;
    wire       rx_valid;

    // UART TX signals
    wire [7:0] tx_data;
    wire       tx_start;
    wire       tx_ready;

    // Instantiate UART Receiver
    uart_rx #(
        .BAUD_DIV(434) // 50 MHz / 115200 = 434 divider
    ) u_uart_rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx(uart_rx_pin),
        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );

    // Instantiate UART Transmitter
    uart_tx #(
        .BAUD_DIV(434)
    ) u_uart_tx (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx(uart_tx_pin),
        .tx_ready(tx_ready)
    );

    // Instantiate Register & Math interface
    uart_register_interface u_reg_if (
        .clk(clk),
        .rst_n(rst_n),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_ready(tx_ready),
        .led_pins(led_pins)
    );

endmodule
