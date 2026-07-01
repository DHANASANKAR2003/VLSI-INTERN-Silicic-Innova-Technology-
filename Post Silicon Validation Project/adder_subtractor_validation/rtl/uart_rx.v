// uart_rx.v
// UART Receiver module
// Baudrate: 115200 at 50 MHz clock (Baud Divider = 50,000,000 / 115200 = 434)

module uart_rx (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,
    output reg  [7:0] rx_data,
    output reg        rx_valid
);
    parameter BAUD_DIV = 434;

    reg [8:0]  clk_cnt;
    reg [1:0]  state;
    reg [2:0]  bit_idx;
    reg [7:0]  shift_reg;
    reg        rx_d1, rx_d2;

    localparam ST_IDLE  = 2'd0,
               ST_START = 2'd1,
               ST_DATA  = 2'd2,
               ST_STOP  = 2'd3;

    // Double-flop rx input to prevent metastability
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_d1 <= 1'b1;
            rx_d2 <= 1'b1;
        end else begin
            rx_d1 <= rx;
            rx_d2 <= rx_d1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= ST_IDLE;
            clk_cnt   <= 0;
            bit_idx   <= 0;
            shift_reg <= 0;
            rx_data   <= 0;
            rx_valid  <= 1'b0;
        end else begin
            rx_valid <= 1'b0;
            case (state)
                ST_IDLE: begin
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    if (!rx_d2) begin // Detect falling edge of start bit
                        state <= ST_START;
                    end
                end
                ST_START: begin
                    if (clk_cnt == (BAUD_DIV / 2) - 1) begin
                        if (!rx_d2) begin // Sample at midpoint to verify start bit is low
                            clk_cnt <= 0;
                            state   <= ST_DATA;
                        end else begin
                            state   <= ST_IDLE;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end
                ST_DATA: begin
                    if (clk_cnt == BAUD_DIV - 1) begin
                        clk_cnt <= 0;
                        shift_reg[bit_idx] <= rx_d2;
                        if (bit_idx == 7) begin
                            state <= ST_STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end
                ST_STOP: begin
                    if (clk_cnt == BAUD_DIV - 1) begin
                        clk_cnt  <= 0;
                        rx_data  <= shift_reg;
                        rx_valid <= 1'b1; // Pulse valid high for 1 clock cycle
                        state    <= ST_IDLE;
                    end else begin
                        clk_cnt  <= clk_cnt + 1;
                    end
                end
                default: state <= ST_IDLE;
            endcase
        end
    end
endmodule
