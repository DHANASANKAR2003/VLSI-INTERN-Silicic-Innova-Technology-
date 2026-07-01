// axi_lite_timer_regs.v
// Free-running/periodic timer register bank.
//   REG0 (0x00): TIMER_CTRL  - RW, bit0 = enable, bit1 = periodic mode
//   REG1 (0x04): TIMER_COUNT - RO, live up-counter value
//   REG2 (0x08): TIMER_LIMIT - RW, reload/compare value for periodic mode
//   REG3 (0x0C): TIMER_STATUS- RO, reserved in this revision (reads 0)
//
// NOTE: the expired flag is exposed directly as timer_expired_pulse for use
// by the parent design (e.g. wired into axi_lite_status_regs' status word)
// rather than duplicated into a second AXI-visible register in this block.

module axi_lite_timer_regs #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input  wire                      clk,
    input  wire                      rst_n,

    input  wire [ADDR_WIDTH-1:0]     s_axi_awaddr,
    input  wire                      s_axi_awvalid,
    output wire                      s_axi_awready,
    input  wire [DATA_WIDTH-1:0]     s_axi_wdata,
    input  wire [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input  wire                      s_axi_wvalid,
    output wire                      s_axi_wready,
    output wire [1:0]                s_axi_bresp,
    output wire                      s_axi_bvalid,
    input  wire                      s_axi_bready,
    input  wire [ADDR_WIDTH-1:0]     s_axi_araddr,
    input  wire                      s_axi_arvalid,
    output wire                      s_axi_arready,
    output wire [DATA_WIDTH-1:0]     s_axi_rdata,
    output wire [1:0]                s_axi_rresp,
    output wire                      s_axi_rvalid,
    input  wire                      s_axi_rready,

    output wire                      timer_expired_pulse
);

    // REG0=RW, REG1=RO, REG2=RW, REG3=RO
    localparam [7:0] TIMER_POLICY = 8'b01_00_01_00;

    wire [31:0] ctrl_reg;
    wire [31:0] limit_reg;
    reg  [31:0] count_reg;
    reg         expired_flag;

    wire timer_enable   = ctrl_reg[0];
    wire timer_periodic = ctrl_reg[1];

    assign timer_expired_pulse = expired_flag;

    // Free-running counter, separate from the AXI register file logic so it
    // keeps counting every cycle regardless of bus traffic.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_reg    <= 32'h0;
            expired_flag <= 1'b0;
        end else if (timer_enable) begin
            if (limit_reg != 32'h0 && count_reg >= limit_reg) begin
                expired_flag <= 1'b1;
                count_reg    <= timer_periodic ? 32'h0 : count_reg;
            end else begin
                count_reg <= count_reg + 1'b1;
            end
        end
    end

    axi_lite_register_block #(
        .ADDR_WIDTH   (ADDR_WIDTH),
        .DATA_WIDTH   (DATA_WIDTH),
        .RESET_VAL0   (32'h0000_0000),
        .RESET_VAL1   (32'h0000_0000),
        .RESET_VAL2   (32'h0000_0000),
        .RESET_VAL3   (32'h0000_0000),
        .ACCESS_POLICY(TIMER_POLICY)
    ) u_reg_block (
        .clk             (clk),
        .rst_n           (rst_n),
        .s_axi_awaddr    (s_axi_awaddr),
        .s_axi_awvalid   (s_axi_awvalid),
        .s_axi_awready   (s_axi_awready),
        .s_axi_wdata     (s_axi_wdata),
        .s_axi_wstrb     (s_axi_wstrb),
        .s_axi_wvalid    (s_axi_wvalid),
        .s_axi_wready    (s_axi_wready),
        .s_axi_bresp     (s_axi_bresp),
        .s_axi_bvalid    (s_axi_bvalid),
        .s_axi_bready    (s_axi_bready),
        .s_axi_araddr    (s_axi_araddr),
        .s_axi_arvalid   (s_axi_arvalid),
        .s_axi_arready   (s_axi_arready),
        .s_axi_rdata     (s_axi_rdata),
        .s_axi_rresp     (s_axi_rresp),
        .s_axi_rvalid    (s_axi_rvalid),
        .s_axi_rready    (s_axi_rready),
        .reg0_out        (ctrl_reg),
        .reg1_out        (),
        .reg2_out        (limit_reg),
        .reg3_out        (),
        .reg1_status_in  (count_reg),
        .reg1_status_load(1'b1)
    );

endmodule
