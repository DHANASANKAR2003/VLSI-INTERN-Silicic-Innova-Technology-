`timescale 1ns/1ps

// ---------------- MASTER ----------------
module i2c_master_fsm (
    input wire clk,
    input wire reset,
    input wire initiate,
    input wire SDA_in,
    output reg SDA_out,
    output reg SCL,
    output reg [2:0] state
);
    parameter IDLE            = 3'd0;
    parameter START_CONDITION = 3'd1;
    parameter SLAVE_ADDRESS   = 3'd2;
    parameter RW_BIT          = 3'd3;
    parameter ACK_BIT         = 3'd4;
    parameter DATA            = 3'd5;
    parameter ACK_1_BIT       = 3'd6;
    parameter STOP_CONDITION  = 3'd7;

    reg [6:0] slave_address = 7'b1010000;
    reg rw = 1'b0; // 0 = write
    reg [7:0] data_byte = 8'b10101010;

    reg [3:0] bit_cnt;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            SDA_out <= 1;
            SCL <= 1;
            bit_cnt <= 0;
        end else begin
            case (state)
                IDLE: begin
                    SDA_out <= 1;
                    SCL <= 1;
                    if (!initiate)
                        state <= START_CONDITION;
                end

                START_CONDITION: begin
                    SDA_out <= 0;
                    SCL <= 1;
                    state <= SLAVE_ADDRESS;
                    bit_cnt <= 6;
                end

                SLAVE_ADDRESS: begin
                    SDA_out <= slave_address[bit_cnt];
                    SCL <= ~SCL;
                    if (SCL) begin
                        if (bit_cnt == 0)
                            state <= RW_BIT;
                        else
                            bit_cnt <= bit_cnt - 1;
                    end
                end

                RW_BIT: begin
                    SDA_out <= rw;
                    SCL <= ~SCL;
                    if (SCL)
                        state <= ACK_BIT;
                end

                ACK_BIT: begin
                    SCL <= ~SCL;
                    if (SCL) begin
                        if (SDA_in == 0)
                            state <= DATA;
                        else
                            state <= STOP_CONDITION;
                        bit_cnt <= 7;
                    end
                end

                DATA: begin
                    SDA_out <= data_byte[bit_cnt];
                    SCL <= ~SCL;
                    if (SCL) begin
                        if (bit_cnt == 0)
                            state <= ACK_1_BIT;
                        else
                            bit_cnt <= bit_cnt - 1;
                    end
                end

                ACK_1_BIT: begin
                    SCL <= ~SCL;
                    if (SCL)
                        state <= STOP_CONDITION;
                end

                STOP_CONDITION: begin
                    SDA_out <= 0;
                    SCL <= 1;
                    SDA_out <= 1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule

// ---------------- SLAVE ----------------
module i2c_slave_ack (
    input wire clk,
    input wire SCL,
    input wire SDA_out,
    input wire [2:0] master_state,
    output reg SDA_in
);
    always @(posedge clk) begin
        if (master_state == 3'd4 || master_state == 3'd6)
            SDA_in <= 0; // ACK
        else
            SDA_in <= 1; // Release line (high-Z simulated)
    end
endmodule

// ---------------- TESTBENCH ----------------
module tb_i2c_master_slave;

    reg clk = 0;
    reg reset;
    reg initiate;
    wire SDA;
    wire SCL;
    wire [2:0] state;

    wire SDA_out;
    wire SDA_in;

    always #10 clk = ~clk; // 50 MHz

    i2c_master_fsm master (
        .clk(clk),
        .reset(reset),
        .initiate(initiate),
        .SDA_in(SDA),
        .SDA_out(SDA_out),
        .SCL(SCL),
        .state(state)
    );

    i2c_slave_ack slave (
        .clk(clk),
        .SCL(SCL),
        .SDA_out(SDA_out),
        .master_state(state),
        .SDA_in(SDA_in)
    );

    assign SDA = (state == 3'd4 || state == 3'd6) ? SDA_in : SDA_out;

    initial begin
        $dumpfile("i2c_master_slave.vcd");
        $dumpvars(0, tb_i2c_master_slave);

        reset = 1; initiate = 1;
        #100;
        reset = 0;
        #100;
        initiate = 0;
        #2000;

        $display("I2C Master-Slave Write Test Complete.");
        $finish;
    end
endmodule
