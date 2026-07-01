// axi_lite_master_cmd_if.v
// The actual AXI-Lite MASTER in this system. Takes a simple
// addr/data/is_write/valid command from uart_register_interface and drives
// a full AXI-Lite write (AW+W -> B) or read (AR -> R) transaction.
// Includes a timeout counter so the bus cannot hang forever if a slave
// never responds.

`include "axi_lite_pkg_defs.vh"

module axi_lite_master_cmd_if #(
    parameter ADDR_WIDTH    = 32,
    parameter DATA_WIDTH    = 32,
    parameter TIMEOUT_CYCLES = 1024
) (
    input  wire                    clk,
    input  wire                    rst_n,

    // Simple command interface (from uart_register_interface)
    input  wire [ADDR_WIDTH-1:0]   cmd_addr,
    input  wire [DATA_WIDTH-1:0]   cmd_wdata,
    input  wire                    cmd_is_write,
    input  wire                    cmd_valid,
    output reg                     cmd_ready,

    // Simple response interface (to uart_register_interface)
    output reg  [DATA_WIDTH-1:0]   resp_rdata,
    output reg  [1:0]              resp_axi_status,
    output reg                     resp_valid,
    input  wire                    resp_ack,

    // ---------------- AXI-Lite master port ----------------
    output reg  [ADDR_WIDTH-1:0]   m_axi_awaddr,
    output reg                     m_axi_awvalid,
    input  wire                    m_axi_awready,

    output reg  [DATA_WIDTH-1:0]   m_axi_wdata,
    output reg  [(DATA_WIDTH/8)-1:0] m_axi_wstrb,
    output reg                     m_axi_wvalid,
    input  wire                    m_axi_wready,

    input  wire [1:0]              m_axi_bresp,
    input  wire                    m_axi_bvalid,
    output reg                     m_axi_bready,

    output reg  [ADDR_WIDTH-1:0]   m_axi_araddr,
    output reg                     m_axi_arvalid,
    input  wire                    m_axi_arready,

    input  wire [DATA_WIDTH-1:0]   m_axi_rdata,
    input  wire [1:0]              m_axi_rresp,
    input  wire                    m_axi_rvalid,
    output reg                     m_axi_rready,

    // Timeout flag, observed by axi_lite_protocol_checker / reporting
    output reg                     timeout_error
);

    localparam ST_IDLE       = 4'd0,
               ST_AW         = 4'd1,
               ST_W          = 4'd2,
               ST_B          = 4'd3,
               ST_AR         = 4'd4,
               ST_R          = 4'd5,
               ST_RESPOND    = 4'd6,
               ST_WAIT_ACK   = 4'd7;

    reg [3:0]  state;
    reg        cur_is_write;
    reg [15:0] timeout_count;

    wire aw_done = m_axi_awvalid && m_axi_awready;
    wire w_done  = m_axi_wvalid  && m_axi_wready;
    wire b_done  = m_axi_bvalid  && m_axi_bready;
    wire ar_done = m_axi_arvalid && m_axi_arready;
    wire r_done  = m_axi_rvalid  && m_axi_rready;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state           <= ST_IDLE;
            cmd_ready       <= 1'b1;
            cur_is_write    <= 1'b0;
            m_axi_awaddr    <= {ADDR_WIDTH{1'b0}};
            m_axi_awvalid   <= 1'b0;
            m_axi_wdata     <= {DATA_WIDTH{1'b0}};
            m_axi_wstrb     <= {(DATA_WIDTH/8){1'b1}};
            m_axi_wvalid    <= 1'b0;
            m_axi_bready    <= 1'b0;
            m_axi_araddr    <= {ADDR_WIDTH{1'b0}};
            m_axi_arvalid   <= 1'b0;
            m_axi_rready    <= 1'b0;
            resp_rdata      <= {DATA_WIDTH{1'b0}};
            resp_axi_status <= `AXI_RESP_OKAY;
            resp_valid      <= 1'b0;
            timeout_count   <= 16'd0;
            timeout_error   <= 1'b0;
        end else begin
            case (state)
                ST_IDLE: begin
                    cmd_ready     <= 1'b1;
                    resp_valid    <= 1'b0;
                    timeout_count <= 16'd0;
                    timeout_error <= 1'b0;
                    if (cmd_valid && cmd_ready) begin
                        cmd_ready    <= 1'b0;
                        cur_is_write <= cmd_is_write;
                        if (cmd_is_write) begin
                            m_axi_awaddr  <= cmd_addr;
                            m_axi_awvalid <= 1'b1;
                            m_axi_wdata   <= cmd_wdata;
                            m_axi_wvalid  <= 1'b1;
                            state         <= ST_AW;
                        end else begin
                            m_axi_araddr  <= cmd_addr;
                            m_axi_arvalid <= 1'b1;
                            state         <= ST_AR;
                        end
                    end
                end

                // ---------------- WRITE PATH ----------------
                ST_AW: begin
                    if (aw_done) m_axi_awvalid <= 1'b0;
                    if (w_done)  m_axi_wvalid  <= 1'b0;

                    if ((aw_done || !m_axi_awvalid) && (w_done || !m_axi_wvalid)) begin
                        m_axi_bready <= 1'b1;
                        state        <= ST_B;
                    end else if (timeout_count == TIMEOUT_CYCLES) begin
                        timeout_error <= 1'b1;
                        m_axi_awvalid <= 1'b0;
                        m_axi_wvalid  <= 1'b0;
                        state         <= ST_RESPOND;
                        resp_axi_status <= `AXI_RESP_SLVERR;
                    end else begin
                        timeout_count <= timeout_count + 1'b1;
                    end
                end

                ST_B: begin
                    if (b_done) begin
                        m_axi_bready    <= 1'b0;
                        resp_axi_status <= m_axi_bresp;
                        resp_rdata      <= cmd_wdata; // echo write data back
                        state           <= ST_RESPOND;
                    end else if (timeout_count == TIMEOUT_CYCLES) begin
                        timeout_error   <= 1'b1;
                        m_axi_bready    <= 1'b0;
                        resp_axi_status <= `AXI_RESP_SLVERR;
                        state           <= ST_RESPOND;
                    end else begin
                        timeout_count <= timeout_count + 1'b1;
                    end
                end

                // ---------------- READ PATH ----------------
                ST_AR: begin
                    if (ar_done) begin
                        m_axi_arvalid <= 1'b0;
                        m_axi_rready  <= 1'b1;
                        state         <= ST_R;
                    end else if (timeout_count == TIMEOUT_CYCLES) begin
                        timeout_error   <= 1'b1;
                        m_axi_arvalid   <= 1'b0;
                        resp_axi_status <= `AXI_RESP_SLVERR;
                        state           <= ST_RESPOND;
                    end else begin
                        timeout_count <= timeout_count + 1'b1;
                    end
                end

                ST_R: begin
                    if (r_done) begin
                        m_axi_rready    <= 1'b0;
                        resp_rdata      <= m_axi_rdata;
                        resp_axi_status <= m_axi_rresp;
                        state           <= ST_RESPOND;
                    end else if (timeout_count == TIMEOUT_CYCLES) begin
                        timeout_error   <= 1'b1;
                        m_axi_rready    <= 1'b0;
                        resp_axi_status <= `AXI_RESP_SLVERR;
                        state           <= ST_RESPOND;
                    end else begin
                        timeout_count <= timeout_count + 1'b1;
                    end
                end

                ST_RESPOND: begin
                    resp_valid <= 1'b1;
                    state      <= ST_WAIT_ACK;
                end

                ST_WAIT_ACK: begin
                    if (resp_ack) begin
                        resp_valid <= 1'b0;
                        state      <= ST_IDLE;
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule
