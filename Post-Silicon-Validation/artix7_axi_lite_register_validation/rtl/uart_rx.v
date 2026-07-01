// uart_rx.v
// UART Receiver: deserializes incoming UART bits into parallel bytes.
// Standard 8N1 framing: 1 start bit (0), 8 data bits LSB-first, 1 stop bit (1).

module uart_rx #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115_200
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,          // serial input pin
    output reg  [7:0] rx_data,     // received byte
    output reg        rx_valid,    // pulses high for 1 cycle when rx_data is valid
    output reg        rx_error     // framing error (stop bit not seen as 1)
);

    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;

    localparam IDLE  = 3'd0,
               START  = 3'd1,
               DATA   = 3'd2,
               STOP   = 3'd3,
               CLEANUP= 3'd4;

    reg [2:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  rx_shift;
    reg        rx_sync_0, rx_sync_1; // double-flop for metastability

    // Synchronize asynchronous rx input into clk domain
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync_0 <= 1'b1;
            rx_sync_1 <= 1'b1;
        end else begin
            rx_sync_0 <= rx;
            rx_sync_1 <= rx_sync_0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            clk_count <= 16'd0;
            bit_index <= 3'd0;
            rx_shift  <= 8'd0;
            rx_data   <= 8'd0;
            rx_valid  <= 1'b0;
            rx_error  <= 1'b0;
        end else begin
            rx_valid <= 1'b0; // default: deassert unless explicitly set below

            case (state)
                IDLE: begin
                    rx_error  <= 1'b0;
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;
                    if (rx_sync_1 == 1'b0) begin // start bit detected
                        state <= START;
                    end
                end

                START: begin
                    // sample at the middle of the start bit to confirm validity
                    if (clk_count == (BAUD_DIV / 2)) begin
                        if (rx_sync_1 == 1'b0) begin
                            clk_count <= 16'd0;
                            state     <= DATA;
                        end else begin
                            state <= IDLE; // false start, glitch
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                DATA: begin
                    if (clk_count == BAUD_DIV - 1) begin
                        clk_count           <= 16'd0;
                        rx_shift[bit_index] <= rx_sync_1;
                        if (bit_index == 3'd7) begin
                            bit_index <= 3'd0;
                            state     <= STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                STOP: begin
                    if (clk_count == BAUD_DIV - 1) begin
                        clk_count <= 16'd0;
                        if (rx_sync_1 == 1'b1) begin
                            rx_data  <= rx_shift;
                            rx_valid <= 1'b1;
                            rx_error <= 1'b0;
                        end else begin
                            rx_error <= 1'b1; // framing error
                        end
                        state <= CLEANUP;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                CLEANUP: begin
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
