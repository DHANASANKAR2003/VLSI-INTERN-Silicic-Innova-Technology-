// uart_tx.v
// UART Transmitter: serializes a parallel byte into 8N1 UART framing.

module uart_tx #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115_200
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] tx_data,   // byte to transmit
    input  wire       tx_start,  // pulse high for 1 cycle to begin transmission
    output reg        tx,        // serial output pin
    output reg        tx_busy    // high while a transmission is in progress
);

    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;

    localparam IDLE  = 2'd0,
               START = 2'd1,
               DATA  = 2'd2,
               STOP  = 2'd3;

    reg [1:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  tx_shift;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            clk_count <= 16'd0;
            bit_index <= 3'd0;
            tx_shift  <= 8'd0;
            tx        <= 1'b1; // idle line is high
            tx_busy   <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    if (tx_start) begin
                        tx_shift  <= tx_data;
                        tx_busy   <= 1'b1;
                        clk_count <= 16'd0;
                        state     <= START;
                    end else begin
                        tx_busy <= 1'b0;
                    end
                end

                START: begin
                    tx <= 1'b0; // start bit
                    if (clk_count == BAUD_DIV - 1) begin
                        clk_count <= 16'd0;
                        bit_index <= 3'd0;
                        state     <= DATA;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                DATA: begin
                    tx <= tx_shift[bit_index];
                    if (clk_count == BAUD_DIV - 1) begin
                        clk_count <= 16'd0;
                        if (bit_index == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                STOP: begin
                    tx <= 1'b1; // stop bit
                    if (clk_count == BAUD_DIV - 1) begin
                        clk_count <= 16'd0;
                        tx_busy   <= 1'b0;
                        state     <= IDLE;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
