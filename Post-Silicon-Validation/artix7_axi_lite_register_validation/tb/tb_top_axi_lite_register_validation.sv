// tb_top_axi_lite_register_validation.sv
// Top-level integration testbench for top_axi_lite_register_validation.v
// Drives the design exactly the way the host PC would: serializes UART byte
// sequences onto uart_rx_pin and captures bytes coming back on uart_tx_pin,
// then checks the decoded response. This is the closest sim-only proxy for
// the real Python/serial_driver.py <-> FPGA interaction used on hardware.

`timescale 1ns/1ps

module tb_top_axi_lite_register_validation;

    localparam CLK_PERIOD  = 20;          // 50 MHz
    localparam BAUD_RATE   = 1_000_000;   // fast baud in sim to keep runtime reasonable
    localparam CLK_FREQ    = 50_000_000;
    localparam BIT_TIME_NS = (1_000_000_000 / BAUD_RATE);

    reg clk = 0;
    reg rst_n_pin = 0;
    reg uart_rx_pin = 1'b1; // idle high
    wire uart_tx_pin;
    wire [15:0] led_pins;
    reg  [15:0] switch_pins = 16'h0;

    integer pass_count = 0;
    integer fail_count = 0;

    top_axi_lite_register_validation #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk        (clk),
        .rst_n_pin  (rst_n_pin),
        .uart_rx_pin(uart_rx_pin),
        .uart_tx_pin(uart_tx_pin),
        .led_pins   (led_pins),
        .switch_pins(switch_pins)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    task check(string name, logic cond);
        if (cond) begin pass_count++; $display("[PASS] %s", name); end
        else begin fail_count++; $display("[FAIL] %s", name); end
    endtask

    // ---------------- UART byte-level drive/capture helpers ----------------
    task automatic uart_send_byte(input [7:0] data);
        integer i;
        begin
            uart_rx_pin = 1'b0; // start bit
            #(BIT_TIME_NS);
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx_pin = data[i];
                #(BIT_TIME_NS);
            end
            uart_rx_pin = 1'b1; // stop bit
            #(BIT_TIME_NS);
        end
    endtask

    task automatic uart_send_packet_write(input [31:0] addr, input [31:0] data);
        begin
            uart_send_byte(8'h57); // 'W'
            uart_send_byte(addr[31:24]);
            uart_send_byte(addr[23:16]);
            uart_send_byte(addr[15:8]);
            uart_send_byte(addr[7:0]);
            uart_send_byte(data[31:24]);
            uart_send_byte(data[23:16]);
            uart_send_byte(data[15:8]);
            uart_send_byte(data[7:0]);
        end
    endtask

    task automatic uart_send_packet_read(input [31:0] addr);
        begin
            uart_send_byte(8'h52); // 'R'
            uart_send_byte(addr[31:24]);
            uart_send_byte(addr[23:16]);
            uart_send_byte(addr[15:8]);
            uart_send_byte(addr[7:0]);
        end
    endtask

    // Captures one byte from uart_tx_pin (assumes idle-high, 8N1)
    task automatic uart_capture_byte(output [7:0] data_out);
        integer i;
        begin
            wait (uart_tx_pin == 1'b0); // wait for start bit
            #(BIT_TIME_NS * 1.5); // move to middle of first data bit
            for (i = 0; i < 8; i = i + 1) begin
                data_out[i] = uart_tx_pin;
                #(BIT_TIME_NS);
            end
            // remaining time lands in the stop bit; no need to sample it
        end
    endtask

    task automatic uart_capture_response(output [7:0] status, output [31:0] data, output [7:0] resp_type);
        reg [7:0] b0, b1, b2, b3, b4, b5;
        begin
            uart_capture_byte(b0); // status
            uart_capture_byte(b1); // data[31:24]
            uart_capture_byte(b2); // data[23:16]
            uart_capture_byte(b3); // data[15:8]
            uart_capture_byte(b4); // data[7:0]
            uart_capture_byte(b5); // resp type
            status    = b0;
            data      = {b1, b2, b3, b4};
            resp_type = b5;
        end
    endtask

    reg [7:0]  resp_status, resp_type;
    reg [31:0] resp_data;

    initial begin
        rst_n_pin = 1;
        repeat (10) @(posedge clk);
        rst_n_pin = 0;
        repeat (20) @(posedge clk);

        // ---- Test 1: write to GPIO scratch register (0x0C), read it back ----
        fork
            uart_send_packet_write(32'h0000_000C, 32'hDEAD_BEEF);
            uart_capture_response(resp_status, resp_data, resp_type);
        join
        check("write to GPIO scratch reg gets OKAY status", resp_status == 8'h00);
        check("write response echoes resp_type as write", resp_type == 8'h57);

        fork
            uart_send_packet_read(32'h0000_000C);
            uart_capture_response(resp_status, resp_data, resp_type);
        join
        check("readback of GPIO scratch reg matches written value", resp_data == 32'hDEAD_BEEF);
        check("read status is OKAY", resp_status == 8'h00);

        // ---- Test 2: read DEVICE_ID from status regs (0x0100) ----
        fork
            uart_send_packet_read(32'h0000_0100);
            uart_capture_response(resp_status, resp_data, resp_type);
        join
        check("DEVICE_ID read returns OKAY", resp_status == 8'h00);
        check("DEVICE_ID matches expected fixed value", resp_data == 32'hA5A5_0009);

        // ---- Test 3: illegal/unmapped address access -> DECERR ----
        fork
            uart_send_packet_read(32'h0000_9999);
            uart_capture_response(resp_status, resp_data, resp_type);
        join
        check("unmapped address read returns DECERR status", resp_status == 8'h02);

        // ---- Test 4: write to RO status flags register should not corrupt it ----
        fork
            uart_send_packet_write(32'h0000_0104, 32'hFFFF_FFFF); // STATUS_FLAGS is RO
            uart_capture_response(resp_status, resp_data, resp_type);
        join
        check("write to RO status flags still gets OKAY (silently dropped)", resp_status == 8'h00);

        fork
            uart_send_packet_read(32'h0000_0104);
            uart_capture_response(resp_status, resp_data, resp_type);
        join
        check("STATUS_FLAGS unaffected by illegal write attempt", resp_data[31:4] == 28'h0);

        // ---- Test 5: timer enable then confirm count increments ----
        fork
            uart_send_packet_write(32'h0000_0200, 32'h0000_0001); // TIMER_CTRL enable
            uart_capture_response(resp_status, resp_data, resp_type);
        join
        repeat (50) @(posedge clk);
        fork
            uart_send_packet_read(32'h0000_0204); // TIMER_COUNT
            uart_capture_response(resp_status, resp_data, resp_type);
        join
        check("timer count is nonzero after enabling and waiting", resp_data > 32'h0);

        $display("---------------------------------------------------");
        $display("TB_TOP_AXI_LITE_REGISTER_VALIDATION: %0d passed, %0d failed", pass_count, fail_count);
        if (fail_count == 0) $display("RESULT: ALL TESTS PASSED");
        else $display("RESULT: FAILURES DETECTED");
        $finish;
    end

    initial begin
        #2_000_000;
        $display("[TIMEOUT] Testbench did not finish in time");
        $finish;
    end

endmodule
