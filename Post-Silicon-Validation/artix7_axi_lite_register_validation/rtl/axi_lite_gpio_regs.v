// axi_lite_gpio_regs.v
// GPIO register bank: 4 general-purpose RW registers at offsets 0x00-0x0C.
//   REG0 (0x00): GPIO_OUT   - drives gpio_out_pins
//   REG1 (0x04): GPIO_IN    - reflects gpio_in_pins (read-only snapshot)
//   REG2 (0x08): GPIO_DIR   - direction control (1 = output, 0 = input), RW
//   REG3 (0x0C): SCRATCH    - free-use RW scratch register, useful for
//                             bit-bash and back-to-back read/write tests

module axi_lite_gpio_regs #(
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

    output wire [31:0]               gpio_out_pins,
    input  wire [31:0]               gpio_in_pins
);

    // REG1 (GPIO_IN) is treated as RO and continuously loaded from the pins.
    localparam [7:0] GPIO_POLICY = 8'b00_00_01_00; // reg3=RW reg2=RW reg1=RO reg0=RW

    axi_lite_register_block #(
        .ADDR_WIDTH   (ADDR_WIDTH),
        .DATA_WIDTH   (DATA_WIDTH),
        .RESET_VAL0   (32'h0000_0000),
        .RESET_VAL1   (32'h0000_0000),
        .RESET_VAL2   (32'h0000_0000),
        .RESET_VAL3   (32'h0000_0000),
        .ACCESS_POLICY(GPIO_POLICY)
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
        .reg0_out        (gpio_out_pins),
        .reg1_out        (),
        .reg2_out        (),
        .reg3_out        (),
        .reg1_status_in  (gpio_in_pins),
        .reg1_status_load(1'b1)
    );

endmodule
