///////////////////////////////////////////////////////////////////////////////////////////
//       I2C Master FSM                                                                  //
//       Design Code                                                                     //
///////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module i2c_master_fsm (
    input wire clk,           // System clock
    input wire reset,
    input wire initiate,
    input wire SDA_in,
    output reg SDA_out,
    output reg SCL,
    output reg [2:0] state
);

    // FSM state encoding
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
    reg scl_enable;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            SDA_out <= 1;
            SCL <= 1;
            scl_enable <= 0;
            bit_cnt <= 0;
        end else begin
            case (state)
                IDLE: begin
                    SDA_out <= 1;
                    SCL <= 1;
                    scl_enable <= 0;
                    if (initiate == 0) begin
                        state <= START_CONDITION;
                    end
                end

                START_CONDITION: begin
                    SDA_out <= 0; // SDA goes low while SCL is high
                    SCL <= 1;
                    state <= SLAVE_ADDRESS;
                    bit_cnt <= 6;
                end

                SLAVE_ADDRESS: begin
                    SDA_out <= slave_address[bit_cnt];
                    SCL <= ~SCL;
                    if (SCL == 1) begin
                        if (bit_cnt == 0)
                            state <= RW_BIT;
                        else
                            bit_cnt <= bit_cnt - 1;
                    end
                end

                RW_BIT: begin
                    SDA_out <= rw;
                    SCL <= ~SCL;
                    if (SCL == 1)
                        state <= ACK_BIT;
                end

                ACK_BIT: begin
                    SCL <= ~SCL;
                    if (SCL == 1) begin
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
                    if (SCL == 1) begin
                        if (bit_cnt == 0)
                            state <= ACK_1_BIT;
                        else
                            bit_cnt <= bit_cnt - 1;
                    end
                end

                ACK_1_BIT: begin
                    SCL <= ~SCL;
                    if (SCL == 1)
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

///////////////////////////////////////////////////////////////////////////////////////////
//       I2C Master FSM                                                                  //
//       Test Bench code Code                                                            //
///////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module tb_i2c_master_fsm;

    reg clk;
    reg reset;
    reg initiate;
    wire SDA;
    reg SDA_slave_drive;
    reg SDA_slave_data;
    wire SDA_in;
    wire SDA_out;
    wire SCL;
    wire [2:0] state;

    reg [79:0] state_str;

    // Clock generation (50 MHz)
    initial clk = 0;
    always #10 clk = ~clk;

    i2c_master_fsm uut (
        .clk(clk),
        .reset(reset),
        .initiate(initiate),
        .SDA_in(SDA_in),
        .SDA_out(SDA_out),
        .SCL(SCL),
        .state(state)
    );

    assign SDA = SDA_slave_drive ? SDA_out : SDA_slave_data;
    assign SDA_in = SDA;

    // Assign state_str for $monitor
    always @(*) begin
        case (state)
            3'd0: state_str = "IDLE";
            3'd1: state_str = "START_CONDITION";
            3'd2: state_str = "SLAVE_ADDRESS";
            3'd3: state_str = "RW_BIT";
            3'd4: state_str = "ACK_BIT";
            3'd5: state_str = "DATA";
            3'd6: state_str = "ACK_1_BIT";
            3'd7: state_str = "STOP_CONDITION";
            default: state_str = "UNKNOWN";
        endcase
    end

    // Use simple signal in $monitor
    initial begin
        $monitor("Time=%0t | State=%s | SDA_out=%b | SDA_in=%b | SCL=%b", 
                  $time, state_str, SDA_out, SDA_in, SCL);
    end

    initial begin
        $dumpfile("i2c_master.vcd");
        $dumpvars(0, tb_i2c_master_fsm);

        $display("==== Initializing Test ====");
        reset = 1;
        initiate = 1;
        SDA_slave_drive = 1;
        SDA_slave_data = 1;

        #100;
        reset = 0;
        $display("  Deasserting reset");

        #100;
        initiate = 0;
        $display("  Initiating I2C transaction");

        wait (state == 4); // ACK_BIT
        $display(" Entered ACK_BIT state. Simulating ACK from slave...");
        SDA_slave_drive = 0;
        SDA_slave_data = 0;
        #40;
        SDA_slave_drive = 1;

        wait (state == 6); // ACK_1_BIT
        $display(" Entered ACK_1_BIT state. Simulating ACK from slave...");
        SDA_slave_drive = 0;
        SDA_slave_data = 0;
        #40;
        SDA_slave_drive = 1;

        wait (state == 0); // IDLE
        $display(" FSM returned to IDLE. I2C operation complete.");
        #100;

        $display(" I2C FSM Test Completed Successfully.");
        $finish;
    end

endmodule
