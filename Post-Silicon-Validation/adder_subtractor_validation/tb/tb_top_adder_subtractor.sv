// tb_top_adder_subtractor.sv
// Simplified testbench for 8-Bit Adder/Subtractor.
// Protocol: Sends 3 bytes [OP_A], [OP_B], [CTRL] (0 = Add, 1 = Sub)
// Receives 2 bytes [RESULT], [CARRY_BORROW]

`timescale 1ns/1ps

module tb_top_adder_subtractor;

    reg        clk;
    reg        rst_n_pin;
    reg        uart_rx_pin;
    wire       uart_tx_pin;
    wire [7:0] led_pins;

    // Instantiate UUT
    top_adder_subtractor uut (
        .clk(clk),
        .rst_n_pin(rst_n_pin),
        .uart_rx_pin(uart_rx_pin),
        .uart_tx_pin(uart_tx_pin),
        .led_pins(led_pins)
    );

    // Clock generation (50 MHz = 20 ns period)
    initial clk = 0;
    always #10 clk = ~clk;

    // Bit period for 115200 baud = 8680 ns
    localparam BIT_PERIOD = 8680;

    // Task to send a single byte over UART
    task automatic send_uart_byte(input [7:0] byte_data);
        integer i;
        begin
            // Start Bit (Low)
            uart_rx_pin = 1'b0;
            #BIT_PERIOD;

            // 8 Data Bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx_pin = byte_data[i];
                #BIT_PERIOD;
            end

            // Stop Bit (High)
            uart_rx_pin = 1'b1;
            #BIT_PERIOD;
            #1000; // Small gap between bytes
        end
    endtask

    // Task to send a complete operation packet
    task automatic send_operation(input [7:0] a, input [7:0] b, input [7:0] ctrl);
        begin
            $display("[TB] Sending Operation: A=%d, B=%d, CTRL=%d", a, b, ctrl);
            send_uart_byte(a);
            send_uart_byte(b);
            send_uart_byte(ctrl);
        end
    endtask

    // Listen to UART TX response (receives 2 bytes)
    reg [7:0] rx_bytes [0:1];
    reg [7:0] rx_byte;
    integer   rx_cnt;
    integer   bit_cnt;
    event     response_received;

    initial begin
        rx_cnt = 0;
        forever begin
            @(negedge uart_tx_pin); // Wait for start bit
            #(BIT_PERIOD / 2);      // Wait to align to midpoint
            #(BIT_PERIOD);          // Wait for first data bit
            
            // Capture 8 data bits
            for (bit_cnt = 0; bit_cnt < 8; bit_cnt = bit_cnt + 1) begin
                rx_byte[bit_cnt] = uart_tx_pin;
                #(BIT_PERIOD);
            end
            
            rx_bytes[rx_cnt] = rx_byte;
            rx_cnt = rx_cnt + 1;
            
            if (rx_cnt == 2) begin
                $display("[TB] Received Response: Result=%d, Carry/Borrow=%d", rx_bytes[0], rx_bytes[1]);
                rx_cnt = 0;
                -> response_received;
            end
        end
    end

    // List of test vectors (5 additions, 5 subtractions)
    reg [7:0] test_a    [0:9];
    reg [7:0] test_b    [0:9];
    reg [7:0] test_ctrl [0:9];
    
    // Expected values
    reg [7:0] exp_res   [0:9];
    reg       exp_cb    [0:9];

    integer test_idx;
    integer pass_count = 0;

    initial begin
        // Initialize test vectors
        test_a[0] = 8'd120; test_b[0] = 8'd30;  test_ctrl[0] = 8'd0; exp_res[0] = 8'd150; exp_cb[0] = 1'b0;
        test_a[1] = 8'd45;  test_b[1] = 8'd55;  test_ctrl[1] = 8'd0; exp_res[1] = 8'd100; exp_cb[1] = 1'b0;
        test_a[2] = 8'd200; test_b[2] = 8'd100; test_ctrl[2] = 8'd0; exp_res[2] = 8'd44;  exp_cb[2] = 1'b1;
        test_a[3] = 8'd255; test_b[3] = 8'd1;   test_ctrl[3] = 8'd0; exp_res[3] = 8'd0;   exp_cb[3] = 1'b1;
        test_a[4] = 8'd0;   test_b[4] = 8'd0;   test_ctrl[4] = 8'd0; exp_res[4] = 8'd0;   exp_cb[4] = 1'b0;
        test_a[5] = 8'd120; test_b[5] = 8'd30;  test_ctrl[5] = 8'd1; exp_res[5] = 8'd90;  exp_cb[5] = 1'b0;
        test_a[6] = 8'd50;  test_b[6] = 8'd20;  test_ctrl[6] = 8'd1; exp_res[6] = 8'd30;  exp_cb[6] = 1'b0;
        test_a[7] = 8'd10;  test_b[7] = 8'd20;  test_ctrl[7] = 8'd1; exp_res[7] = 8'd246; exp_cb[7] = 1'b1;
        test_a[8] = 8'd0;   test_b[8] = 8'd5;   test_ctrl[8] = 8'd1; exp_res[8] = 8'd251; exp_cb[8] = 1'b1;
        test_a[9] = 8'd255; test_b[9] = 8'd0;   test_ctrl[9] = 8'd1; exp_res[9] = 8'd255; exp_cb[9] = 1'b0;

        $dumpfile("sim_top_adder_subtractor.vcd");
        $dumpvars(0, tb_top_adder_subtractor);

        uart_rx_pin = 1'b1; // Idle state

        // Power-on reset
        rst_n_pin = 1'b1;
        #100;
        rst_n_pin = 1'b0;
        #100;

        $display("[TB] Starting 5 Addition & 5 Subtraction Test Suite...");

        for (test_idx = 0; test_idx < 10; test_idx = test_idx + 1) begin
            send_operation(test_a[test_idx], test_b[test_idx], test_ctrl[test_idx]);
            @response_received;
            
            // Check output
            if ((rx_bytes[0] == exp_res[test_idx]) && (rx_bytes[1][0] == exp_cb[test_idx])) begin
                $display("[TB] TEST %0d PASSED! A=8'b%08b (%0d), B=8'b%08b (%0d), CTRL=1'b%01b | Result=8'b%08b (Exp:8'b%08b), Carry/Borrow=1'b%01b (Exp:1'b%01b)",
                         test_idx+1, test_a[test_idx], test_a[test_idx], test_b[test_idx], test_b[test_idx], test_ctrl[test_idx][0],
                         rx_bytes[0], exp_res[test_idx], rx_bytes[1][0], exp_cb[test_idx]);
                pass_count = pass_count + 1;
            end else begin
                $display("[TB] TEST %0d FAILED! A=8'b%08b (%0d), B=8'b%08b (%0d), CTRL=1'b%01b | Result=8'b%08b (Exp:8'b%08b), Carry/Borrow=1'b%01b (Exp:1'b%01b)",
                         test_idx+1, test_a[test_idx], test_a[test_idx], test_b[test_idx], test_b[test_idx], test_ctrl[test_idx][0],
                         rx_bytes[0], exp_res[test_idx], rx_bytes[1][0], exp_cb[test_idx]);
            end
            #10000; // Small delay between tests
        end

        $display("--------------------------------------------------");
        $display("[TB] Simulation Completed. Passed %0d/10 tests.", pass_count);
        $display("--------------------------------------------------");
        $finish;
    end

endmodule
