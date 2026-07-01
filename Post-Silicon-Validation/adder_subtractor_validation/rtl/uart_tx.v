// uart_tx.v
// UART Transmitter module
// Baudrate: 115200 at 50 MHz clock (Baud Divider = 50,000,000 / 115200 = 434)

module uart_tx (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] tx_data,
    input  wire       tx_start,
    output reg        tx,
    output reg        tx_ready
);
    parameter BAUD_DIV = 434;

    reg [8:0]  clk_cnt;
    reg [1:0]  state;
    reg [2:0]  bit_idx;
    reg [7:0]  shift_reg;

    localparam ST_IDLE  = 2'd0,
               ST_START = 2'd1,
               ST_DATA  = 2'd2,
               ST_STOP  = 2'd3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= ST_IDLE;
            clk_cnt   <= 0;
            bit_idx   <= 0;
            shift_reg <= 0;
            tx        <= 1'b1; // Idle line is high
            tx_ready  <= 1'b1;
        end else begin
            case (state)
                ST_IDLE: begin
                    tx       <= 1'b1;
                    tx_ready <= 1'b1;
                    clk_cnt  <= 0;
                    bit_idx  <= 0;
                    if (tx_start) begin
                        shift_reg <= tx_data;
                        tx_ready  <= 1'b0;
                        tx        <= 1'b0; // Start bit is low
                        state     <= ST_START;
                    end
                end
                ST_START: begin
                    if (clk_cnt == BAUD_DIV - 1) begin
                        clk_cnt <= 0;
                        tx      <= shift_reg[0]; // Send LSB first
                        state   <= ST_DATA;
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end
                ST_DATA: begin
                    if (clk_cnt == BAUD_DIV - 1) begin
                        clk_cnt <= 0;
                        if (bit_idx == 7) begin
                            tx    <= 1'b1; // Stop bit is high
                            state <= ST_STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                            tx      <= shift_reg[bit_idx + 1];
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end
                ST_STOP: begin
                    if (clk_cnt == BAUD_DIV - 1) begin
                        clk_cnt  <= 0;
                        tx_ready <= 1'b1;
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
