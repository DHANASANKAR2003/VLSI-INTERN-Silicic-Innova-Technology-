// uart_register_interface.v
// Sits between uart_rx/uart_tx and axi_lite_master_cmd_if.
// Collects raw UART bytes into a command packet (opcode + address [+ data]),
// hands a completed command to the AXI-Lite master command interface, then
// waits for its response and serializes that response back out over UART.

`include "axi_lite_pkg_defs.vh"

module uart_register_interface (
    input  wire        clk,
    input  wire        rst_n,

    // From uart_rx
    input  wire [7:0]  rx_data,
    input  wire        rx_valid,

    // To uart_tx
    output reg  [7:0]  tx_data,
    output reg         tx_start,
    input  wire        tx_busy,

    // To axi_lite_master_cmd_if
    output reg  [31:0] cmd_addr,
    output reg  [31:0] cmd_wdata,
    output reg         cmd_is_write,
    output reg         cmd_valid,
    input  wire        cmd_ready,

    // From axi_lite_master_cmd_if
    input  wire [31:0] resp_rdata,
    input  wire [1:0]  resp_axi_status,   // AXI_RESP_* encoding
    input  wire        resp_valid,
    output reg         resp_ack
);

    localparam ST_WAIT_OPCODE = 4'd0,
               ST_ADDR_0      = 4'd1,
               ST_ADDR_1      = 4'd2,
               ST_ADDR_2      = 4'd3,
               ST_ADDR_3      = 4'd4,
               ST_DATA_0      = 4'd5,
               ST_DATA_1      = 4'd6,
               ST_DATA_2      = 4'd7,
               ST_DATA_3      = 4'd8,
               ST_ISSUE_CMD   = 4'd9,
               ST_WAIT_RESP   = 4'd10,
               ST_SEND_RESP   = 4'd11;

    reg [3:0]  state;
    reg        is_write_cmd;
    reg [31:0] addr_shift;
    reg [31:0] data_shift;

    // Response transmission byte counter (6 bytes: status + 4 data + resp_type)
    reg [2:0]  tx_byte_idx;
    reg [7:0]  resp_status_byte;
    reg [31:0] resp_data_latched;
    reg [7:0]  resp_type_byte;

    function [7:0] axi_status_to_uart_status (input [1:0] axi_resp);
        case (axi_resp)
            `AXI_RESP_OKAY:   axi_status_to_uart_status = `RESP_OKAY;
            `AXI_RESP_SLVERR: axi_status_to_uart_status = `RESP_SLVERR;
            `AXI_RESP_DECERR: axi_status_to_uart_status = `RESP_DECERR;
            default:          axi_status_to_uart_status = `RESP_SLVERR;
        endcase
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state             <= ST_WAIT_OPCODE;
            is_write_cmd      <= 1'b0;
            addr_shift        <= 32'd0;
            data_shift        <= 32'd0;
            cmd_addr          <= 32'd0;
            cmd_wdata         <= 32'd0;
            cmd_is_write      <= 1'b0;
            cmd_valid         <= 1'b0;
            resp_ack          <= 1'b0;
            tx_data           <= 8'd0;
            tx_start          <= 1'b0;
            tx_byte_idx       <= 3'd0;
            resp_status_byte  <= 8'd0;
            resp_data_latched <= 32'd0;
            resp_type_byte    <= 8'd0;
        end else begin
            // default single-cycle pulses
            cmd_valid <= 1'b0;
            resp_ack  <= 1'b0;
            tx_start  <= 1'b0;

            case (state)
                ST_WAIT_OPCODE: begin
                    if (rx_valid) begin
                        if (rx_data == `OPCODE_WRITE) begin
                            is_write_cmd <= 1'b1;
                            state        <= ST_ADDR_0;
                        end else if (rx_data == `OPCODE_READ) begin
                            is_write_cmd <= 1'b0;
                            state        <= ST_ADDR_0;
                        end
                        // unrecognized opcode bytes are silently dropped
                    end
                end

                ST_ADDR_0: if (rx_valid) begin addr_shift[31:24] <= rx_data; state <= ST_ADDR_1; end
                ST_ADDR_1: if (rx_valid) begin addr_shift[23:16] <= rx_data; state <= ST_ADDR_2; end
                ST_ADDR_2: if (rx_valid) begin addr_shift[15:8]  <= rx_data; state <= ST_ADDR_3; end
                ST_ADDR_3: if (rx_valid) begin
                    addr_shift[7:0] <= rx_data;
                    state <= is_write_cmd ? ST_DATA_0 : ST_ISSUE_CMD;
                end

                ST_DATA_0: if (rx_valid) begin data_shift[31:24] <= rx_data; state <= ST_DATA_1; end
                ST_DATA_1: if (rx_valid) begin data_shift[23:16] <= rx_data; state <= ST_DATA_2; end
                ST_DATA_2: if (rx_valid) begin data_shift[15:8]  <= rx_data; state <= ST_DATA_3; end
                ST_DATA_3: if (rx_valid) begin
                    data_shift[7:0] <= rx_data;
                    state <= ST_ISSUE_CMD;
                end

                ST_ISSUE_CMD: begin
                    cmd_addr     <= addr_shift;
                    cmd_wdata    <= data_shift;
                    cmd_is_write <= is_write_cmd;
                    cmd_valid    <= 1'b1;
                    if (cmd_ready) begin
                        state <= ST_WAIT_RESP;
                    end
                end

                ST_WAIT_RESP: begin
                    if (resp_valid) begin
                        resp_status_byte  <= axi_status_to_uart_status(resp_axi_status);
                        resp_data_latched <= resp_rdata;
                        resp_type_byte    <= is_write_cmd ? `OPCODE_WRITE : `OPCODE_READ;
                        resp_ack          <= 1'b1;
                        tx_byte_idx       <= 3'd0;
                        state             <= ST_SEND_RESP;
                    end
                end

                ST_SEND_RESP: begin
                    if (!tx_busy && !tx_start) begin
                        case (tx_byte_idx)
                            3'd0: begin tx_data <= resp_status_byte;          tx_start <= 1'b1; end
                            3'd1: begin tx_data <= resp_data_latched[31:24];  tx_start <= 1'b1; end
                            3'd2: begin tx_data <= resp_data_latched[23:16];  tx_start <= 1'b1; end
                            3'd3: begin tx_data <= resp_data_latched[15:8];   tx_start <= 1'b1; end
                            3'd4: begin tx_data <= resp_data_latched[7:0];    tx_start <= 1'b1; end
                            3'd5: begin tx_data <= resp_type_byte;            tx_start <= 1'b1; end
                            default: state <= ST_WAIT_OPCODE;
                        endcase
                        if (tx_byte_idx == 3'd5) begin
                            state <= ST_WAIT_OPCODE;
                        end else begin
                            tx_byte_idx <= tx_byte_idx + 1'b1;
                        end
                    end
                end

                default: state <= ST_WAIT_OPCODE;
            endcase
        end
    end

endmodule
