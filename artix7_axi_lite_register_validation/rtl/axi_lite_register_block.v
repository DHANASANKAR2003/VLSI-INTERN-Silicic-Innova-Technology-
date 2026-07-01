// axi_lite_register_block.v
// Generic, reusable AXI-Lite SLAVE containing 4 x 32-bit registers.
// Each register's access policy (RW / RO / WO) and reset value are set via
// parameters, so this single module is instantiated by axi_lite_gpio_regs,
// axi_lite_status_regs, and axi_lite_timer_regs with different config.
//
// Register map (relative offsets from the block's base address):
//   0x00 : REG0
//   0x04 : REG1
//   0x08 : REG2
//   0x0C : REG3
//
// ACCESS_POLICY encoding per register, 2 bits each, packed into an 8-bit vector:
//   2'b00 = RW (read/write)
//   2'b01 = RO (read-only; writes are accepted on the bus but silently dropped)
//   2'b10 = WO (write-only; reads always return 0)

`include "axi_lite_pkg_defs.vh"

module axi_lite_register_block #(
    parameter ADDR_WIDTH     = 32,
    parameter DATA_WIDTH     = 32,
    parameter [31:0] RESET_VAL0 = 32'h0000_0000,
    parameter [31:0] RESET_VAL1 = 32'h0000_0000,
    parameter [31:0] RESET_VAL2 = 32'h0000_0000,
    parameter [31:0] RESET_VAL3 = 32'h0000_0000,
    // ACCESS_POLICY[1:0]=reg0, [3:2]=reg1, [5:4]=reg2, [7:6]=reg3
    parameter [7:0]  ACCESS_POLICY = 8'b00_00_00_00 // default: all RW
) (
    input  wire                      clk,
    input  wire                      rst_n,

    input  wire [ADDR_WIDTH-1:0]     s_axi_awaddr,
    input  wire                      s_axi_awvalid,
    output reg                       s_axi_awready,

    input  wire [DATA_WIDTH-1:0]     s_axi_wdata,
    input  wire [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input  wire                      s_axi_wvalid,
    output reg                       s_axi_wready,

    output reg  [1:0]                s_axi_bresp,
    output reg                       s_axi_bvalid,
    input  wire                      s_axi_bready,

    input  wire [ADDR_WIDTH-1:0]     s_axi_araddr,
    input  wire                      s_axi_arvalid,
    output reg                       s_axi_arready,

    output reg  [DATA_WIDTH-1:0]     s_axi_rdata,
    output reg  [1:0]                s_axi_rresp,
    output reg                       s_axi_rvalid,
    input  wire                      s_axi_rready,

    // Direct register outputs/inputs, for status-pin style usage by parent
    // modules (e.g. wiring REG1 directly to a status pin from external logic)
    output wire [31:0]               reg0_out,
    output wire [31:0]               reg1_out,
    output wire [31:0]               reg2_out,
    output wire [31:0]               reg3_out,
    input  wire [31:0]               reg1_status_in, // overrides reg1 readback when its policy is RO
    input  wire                      reg1_status_load
);

    reg [31:0] reg0, reg1, reg2, reg3;

    wire [1:0] policy0 = ACCESS_POLICY[1:0];
    wire [1:0] policy1 = ACCESS_POLICY[3:2];
    wire [1:0] policy2 = ACCESS_POLICY[5:4];
    wire [1:0] policy3 = ACCESS_POLICY[7:6];

    localparam POLICY_RW = 2'b00,
               POLICY_RO = 2'b01,
               POLICY_WO = 2'b10;

    assign reg0_out = reg0;
    assign reg1_out = reg1;
    assign reg2_out = reg2;
    assign reg3_out = reg3;

    // ---------------- Write channel ----------------
    localparam WST_IDLE = 1'b0, WST_RESP = 1'b1;
    reg wstate;
    reg [3:0] waddr_sel; // one-hot: which register this write targets

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg0          <= RESET_VAL0;
            reg1          <= RESET_VAL1;
            reg2          <= RESET_VAL2;
            reg3          <= RESET_VAL3;
            s_axi_awready <= 1'b1;
            s_axi_wready  <= 1'b1;
            s_axi_bvalid  <= 1'b0;
            s_axi_bresp   <= `AXI_RESP_OKAY;
            wstate        <= WST_IDLE;
            waddr_sel     <= 4'b0000;
        end else begin
            // status register can be loaded externally regardless of bus activity
            if (reg1_status_load && policy1 == POLICY_RO) begin
                reg1 <= reg1_status_in;
            end

            case (wstate)
                WST_IDLE: begin
                    s_axi_bvalid <= 1'b0;
                    if (s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready) begin
                        case (s_axi_awaddr[3:2])
                            2'd0: waddr_sel <= 4'b0001;
                            2'd1: waddr_sel <= 4'b0010;
                            2'd2: waddr_sel <= 4'b0100;
                            2'd3: waddr_sel <= 4'b1000;
                            default: waddr_sel <= 4'b0000;
                        endcase

                        case (s_axi_awaddr[3:2])
                            2'd0: if (policy0 != POLICY_RO) reg0 <= apply_strobe(reg0, s_axi_wdata, s_axi_wstrb);
                            2'd1: if (policy1 != POLICY_RO) reg1 <= apply_strobe(reg1, s_axi_wdata, s_axi_wstrb);
                            2'd2: if (policy2 != POLICY_RO) reg2 <= apply_strobe(reg2, s_axi_wdata, s_axi_wstrb);
                            2'd3: if (policy3 != POLICY_RO) reg3 <= apply_strobe(reg3, s_axi_wdata, s_axi_wstrb);
                            default: ; // unmapped offset within block: ignored, OKAY still returned
                        endcase

                        s_axi_bresp  <= `AXI_RESP_OKAY;
                        s_axi_bvalid <= 1'b1;
                        wstate       <= WST_RESP;
                    end
                end

                WST_RESP: begin
                    if (s_axi_bvalid && s_axi_bready) begin
                        s_axi_bvalid <= 1'b0;
                        wstate       <= WST_IDLE;
                    end
                end
            endcase
        end
    end

    function [31:0] apply_strobe(input [31:0] cur, input [31:0] wdata, input [3:0] wstrb);
        reg [31:0] result;
        begin
            result = cur;
            if (wstrb[0]) result[7:0]   = wdata[7:0];
            if (wstrb[1]) result[15:8]  = wdata[15:8];
            if (wstrb[2]) result[23:16] = wdata[23:16];
            if (wstrb[3]) result[31:24] = wdata[31:24];
            apply_strobe = result;
        end
    endfunction

    // ---------------- Read channel ----------------
    localparam RST_IDLE = 1'b0, RST_RESP = 1'b1;
    reg rstate;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_arready <= 1'b1;
            s_axi_rvalid  <= 1'b0;
            s_axi_rdata   <= {DATA_WIDTH{1'b0}};
            s_axi_rresp   <= `AXI_RESP_OKAY;
            rstate        <= RST_IDLE;
        end else begin
            case (rstate)
                RST_IDLE: begin
                    s_axi_rvalid <= 1'b0;
                    if (s_axi_arvalid && s_axi_arready) begin
                        case (s_axi_araddr[3:2])
                            2'd0: s_axi_rdata <= (policy0 == POLICY_WO) ? 32'h0 : reg0;
                            2'd1: s_axi_rdata <= (policy1 == POLICY_WO) ? 32'h0 : reg1;
                            2'd2: s_axi_rdata <= (policy2 == POLICY_WO) ? 32'h0 : reg2;
                            2'd3: s_axi_rdata <= (policy3 == POLICY_WO) ? 32'h0 : reg3;
                            default: s_axi_rdata <= 32'h0;
                        endcase
                        s_axi_rresp  <= `AXI_RESP_OKAY;
                        s_axi_rvalid <= 1'b1;
                        rstate       <= RST_RESP;
                    end
                end

                RST_RESP: begin
                    if (s_axi_rvalid && s_axi_rready) begin
                        s_axi_rvalid <= 1'b0;
                        rstate       <= RST_IDLE;
                    end
                end
            endcase
        end
    end

endmodule
