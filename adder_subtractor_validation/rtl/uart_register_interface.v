// uart_register_interface.v
// Simple packet interface:
// PC sends 3 bytes: [OP_A], [OP_B], [CTRL] (0 = Add, 1 = Sub)
// FPGA responds with 2 bytes: [RESULT], [CARRY_BORROW]
// led_pins is wired directly to RESULT to display on board.

module uart_register_interface (
    input  wire        clk,
    input  wire        rst_n,

    // UART RX Interface
    input  wire [7:0]  rx_data,
    input  wire        rx_valid,

    // UART TX Interface
    output reg  [7:0]  tx_data,
    output reg         tx_start,
    input  wire        tx_ready,

    // Physical LED output
    output wire [7:0]  led_pins
);

    // Registers to store inputs
    reg [7:0] reg_op_a;
    reg [7:0] reg_op_b;
    reg [7:0] reg_ctrl; // bit 0 = SUB_SEL

    // Internal results
    reg [7:0] math_result;
    reg       carry_borrow;

    // Connect LEDs to the math output directly
    assign led_pins = math_result;

    // State machine
    localparam ST_IDLE       = 3'd0,
               ST_RX_OP_B    = 3'd1,
               ST_RX_CTRL    = 3'd2,
               ST_EXECUTE    = 3'd3,
               ST_TX_RESULT  = 3'd4,
               ST_TX_CARRY   = 3'd5;

    reg [2:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_op_a      <= 8'h00;
            reg_op_b      <= 8'h00;
            reg_ctrl      <= 8'h00;
            math_result   <= 8'h00;
            carry_borrow  <= 1'b0;
            tx_data       <= 8'h00;
            tx_start      <= 1'b0;
            state         <= ST_IDLE;
        end else begin
            tx_start <= 1'b0;

            case (state)
                ST_IDLE: begin
                    if (rx_valid) begin
                        reg_op_a <= rx_data;
                        state    <= ST_RX_OP_B;
                    end
                end

                ST_RX_OP_B: begin
                    if (rx_valid) begin
                        reg_op_b <= rx_data;
                        state    <= ST_RX_CTRL;
                    end
                end

                ST_RX_CTRL: begin
                    if (rx_valid) begin
                        reg_ctrl <= rx_data;
                        state    <= ST_EXECUTE;
                    end
                end

                ST_EXECUTE: begin
                    if (reg_ctrl[0]) begin
                        // Subtraction
                        math_result  <= reg_op_a - reg_op_b;
                        carry_borrow <= (reg_op_a < reg_op_b);
                    end else begin
                        // Addition
                        {carry_borrow, math_result} <= reg_op_a + reg_op_b;
                    end
                    state <= ST_TX_RESULT;
                end

                ST_TX_RESULT: begin
                    if (tx_ready && !tx_start) begin
                        tx_data  <= math_result;
                        tx_start <= 1'b1;
                        state    <= ST_TX_CARRY;
                    end
                end

                ST_TX_CARRY: begin
                    if (tx_ready && !tx_start) begin
                        tx_data  <= {7'b0, carry_borrow};
                        tx_start <= 1'b1;
                        state    <= ST_IDLE;
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule
