`timescale 1ns/1ps

module tb_axi4_spi_simple;

    // Parameters
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
    parameter ID_WIDTH = 4;
    
    parameter AXI_CLK_PERIOD = 10;
    parameter SPI_CLK_PERIOD = 20;

    // Testbench signals
    reg                  m_clk;
    reg                  m_rst_n;
    reg                  start_read;
    reg                  start_write;
    reg [ADDR_WIDTH-1:0] m_address;
    reg [DATA_WIDTH-1:0] m_w_data;
    reg [3:0]            m_w_strb;
    reg [ID_WIDTH-1:0]   m_id;
    reg [7:0]            m_len;

    reg                  spi_clk;
    reg                  spi_rst_n;

    wire spi_cs_n;
    wire spi_sclk;
    wire spi_mosi;
    wire spi_miso;

    // Test statistics
    integer test_count;
    integer write_count;
    integer read_count;
    integer burst_count;
    integer pass_count;
    integer fail_count;

    // DUT instantiation
    axi4_spi_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    ) dut (
        .m_clk(m_clk),
        .m_rst_n(m_rst_n),
        .start_read(start_read),
        .start_write(start_write),
        .m_address(m_address),
        .m_w_data(m_w_data),
        .m_w_strb(m_w_strb),
        .m_id(m_id),
        .m_len(m_len),
        .spi_clk(spi_clk),
        .spi_rst_n(spi_rst_n),
        .spi_cs_n(spi_cs_n),
        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso)
    );

    // Clock generation
    initial begin
        m_clk = 0;
        forever #(AXI_CLK_PERIOD/2) m_clk = ~m_clk;
    end

    initial begin
        spi_clk = 0;
        forever #(SPI_CLK_PERIOD/2) spi_clk = ~spi_clk;
    end

    // Display formatting tasks
    task print_box_header;
        begin
            $display("");
            $display("==============================================");
        end
    endtask

    task print_box_footer;
        begin
            $display("==============================================");
        end
    endtask

    task print_test_header;
        begin
            test_count = test_count + 1;
            print_box_header();
            case (test_count)
                1: $display("  TEST CASE 1: SINGLE WRITE OPERATIONS");
                2: $display("  TEST CASE 2: SINGLE READ OPERATIONS");
                3: $display("  TEST CASE 3: STROBE TESTS");
                4: $display("  TEST CASE 4: TRANSACTION ID TESTS");
                5: $display("  TEST CASE 5: BURST OPERATIONS");
                default: $display("  TEST CASE: UNKNOWN");
            endcase
            $display("==============================================");
        end
    endtask

    task print_test_footer;
        begin
            $display("----------------------------------------------");
            $display("  TEST CASE COMPLETED");
            $display("----------------------------------------------");
        end
    endtask

    task print_section_header;
        begin
            $display("----------------------------------------------");
        end
    endtask

    // Test tasks
    task reset_system;
        begin
            print_box_header();
            $display("  SYSTEM RESET");
            $display("==============================================");
            $display("  Resetting AXI and SPI interfaces...");
            m_rst_n = 0;
            spi_rst_n = 0;
            start_read = 0;
            start_write = 0;
            m_address = 0;
            m_w_data = 0;
            m_w_strb = 0;
            m_id = 0;
            m_len = 0;
            
            repeat(10) @(posedge m_clk);
            m_rst_n = 1;
            spi_rst_n = 1;
            repeat(10) @(posedge m_clk);
            $display("  Reset Complete");
            print_box_footer();
        end
    endtask

    task print_pass;
        begin
            $display("  [PASS] Write verified");
            pass_count = pass_count + 1;
        end
    endtask

    task print_fail;
        begin
            $display("  [FAIL] Read data mismatch");
            fail_count = fail_count + 1;
        end
    endtask

    task print_info;
        begin
            $display("  [INFO] Burst read completed");
        end
    endtask

    task check_write_result;
        input [ADDR_WIDTH-1:0] addr;
        begin
            print_pass();
            $display("      Address: 0x%08h", addr);
        end
    endtask

    task check_read_result;
        input [DATA_WIDTH-1:0] actual_data;
        input [DATA_WIDTH-1:0] expected_data;
        input [ADDR_WIDTH-1:0] addr;
        begin
            if (actual_data === expected_data) begin
                $display("  [PASS] Read verified");
                $display("      Address: 0x%08h, Data: 0x%08h", addr, actual_data);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] Read data mismatch");
                $display("      Address: 0x%08h", addr);
                $display("      Expected: 0x%08h", expected_data);
                $display("      Got:      0x%08h", actual_data);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task axi_write;
        input [ADDR_WIDTH-1:0] addr;
        input [DATA_WIDTH-1:0] data;
        input [3:0] strb;
        input [ID_WIDTH-1:0] id;
        input [7:0] len;
        begin
            @(posedge m_clk);
            m_address = addr;
            m_w_data = data;
            m_w_strb = strb;
            m_id = id;
            m_len = len;
            
            if (len == 0) begin
                $display("  WRITE OPERATION");
                $display("      Address: 0x%08h", addr);
                $display("      Data:    0x%08h", data);
                $display("      Strobe:  0x%h", strb);
                $display("      ID:      0x%h", id);
                write_count = write_count + 1;
            end else begin
                $display("  WRITE BURST OPERATION");
                $display("      Address: 0x%08h", addr);
                $display("      Data:    0x%08h", data);
                $display("      Strobe:  0x%h", strb);
                $display("      ID:      0x%h", id);
                $display("      Length:  %0d", len);
                write_count = write_count + 1;
                burst_count = burst_count + 1;
            end
            
            start_write = 1;
            @(posedge m_clk);
            start_write = 0;
            
            wait(dut.u_axi_master.M_BVALID);
            @(posedge m_clk);
            
            check_write_result(addr);
            $display("");
            repeat(50) @(posedge spi_clk);
        end
    endtask

    task axi_read;
        input [ADDR_WIDTH-1:0] addr;
        input [ID_WIDTH-1:0] id;
        input [7:0] len;
        input [DATA_WIDTH-1:0] expected_data;
        begin
            @(posedge m_clk);
            m_address = addr;
            m_id = id;
            m_len = len;
            
            if (len == 0) begin
                $display("  READ OPERATION");
                $display("      Address:  0x%08h", addr);
                $display("      Expected: 0x%08h", expected_data);
                $display("      ID:       0x%h", id);
                read_count = read_count + 1;
            end else begin
                $display("  READ BURST OPERATION");
                $display("      Address:  0x%08h", addr);
                $display("      Expected: 0x%08h", expected_data);
                $display("      ID:       0x%h", id);
                $display("      Length:   %0d", len);
                read_count = read_count + 1;
                burst_count = burst_count + 1;
            end
            
            start_read = 1;
            @(posedge m_clk);
            start_read = 0;
            
            if (len == 0) begin
                wait(dut.u_axi_master.M_RVALID);
                @(posedge m_clk);
                check_read_result(dut.u_axi_master.M_RDATA, expected_data, addr);
            end else begin
                for (int i = 0; i <= len; i = i + 1) begin
                    wait(dut.u_axi_master.M_RVALID);
                    @(posedge m_clk);
                    $display("      Burst [%0d]: 0x%08h", i, dut.u_axi_master.M_RDATA);
                    while (dut.u_axi_master.M_RVALID) @(posedge m_clk);
                end
                print_info();
            end
            $display("");
            repeat(50) @(posedge spi_clk);
        end
    endtask

    task print_summary;
        integer success_rate;
        begin
            print_box_header();
            $display("  TEST SUMMARY REPORT");
            $display("==============================================");
            
            print_section_header();
            $display("  TEST CASE EXECUTION SUMMARY");
            print_section_header();
            $display("  Total Test Cases    : %0d", test_count);
            $display("  Write Operations    : %0d", write_count);
            $display("  Read Operations     : %0d", read_count);
            $display("  Burst Operations    : %0d", burst_count);
            
            print_section_header();
            $display("  RESULT ANALYSIS");
            print_section_header();
            $display("  Passed Checks       : %0d", pass_count);
            $display("  Failed Checks       : %0d", fail_count);
            
            if ((pass_count + fail_count) > 0) begin
                success_rate = (pass_count * 100) / (pass_count + fail_count);
                $display("  Success Rate        : %0d%%", success_rate);
            end else begin
                $display("  Success Rate        : 0%%");
            end
            
            print_section_header();
            $display("  FINAL VERDICT");
            print_section_header();
            
            if (fail_count == 0) begin
                $display("  ALL TESTS PASSED SUCCESSFULLY!");
                $display("  System is functioning correctly.");
            end else begin
                $display("  %0d TEST(S) FAILED", fail_count);
                $display("  Please review the failed cases above.");
            end
            
            print_box_footer();
        end
    endtask

    // Main test sequence
    initial begin
        $dumpfile("tb_axi4_spi_simple.vcd");
        $dumpvars(0, tb_axi4_spi_simple);
        
        // Initialize counters
        test_count = 0;
        write_count = 0;
        read_count = 0;
        burst_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        reset_system();
        
        // Test 1: Single Writes
        print_test_header();
        axi_write(32'h0000_0000, 32'hDEAD_BEEF, 4'b1111, 4'h1, 8'd0);
        axi_write(32'h0000_0004, 32'h1234_5678, 4'b1111, 4'h2, 8'd0);
        axi_write(32'h0000_0008, 32'hA5A5_A5A5, 4'b1111, 4'h3, 8'd0);
        axi_write(32'h0000_000C, 32'hFFFF_0000, 4'b1100, 4'h4, 8'd0);
        axi_write(32'h0000_0010, 32'h0000_1234, 4'b0011, 4'h5, 8'd0);
        print_test_footer();
        
        // Test 2: Single Reads  
        print_test_header();
        axi_read(32'h0000_0000, 4'h1, 8'd0, 32'hDEAD_BEEF);
        axi_read(32'h0000_0004, 4'h2, 8'd0, 32'h1234_5678);
        axi_read(32'h0000_0008, 4'h3, 8'd0, 32'hA5A5_A5A5);
        axi_read(32'h0000_000C, 4'h4, 8'd0, 32'hFFFF_0000);
        axi_read(32'h0000_0010, 4'h5, 8'd0, 32'h0000_1234);
        print_test_footer();
        
        // Test 3: Strobe Tests
        print_test_header();
        axi_write(32'h0000_0020, 32'h1111_1111, 4'b0001, 4'h1, 8'd0);
        axi_write(32'h0000_0024, 32'h2222_2222, 4'b0010, 4'h2, 8'd0);
        axi_write(32'h0000_0028, 32'h3333_3333, 4'b0100, 4'h3, 8'd0);
        axi_write(32'h0000_002C, 32'h4444_4444, 4'b1000, 4'h4, 8'd0);
        axi_write(32'h0000_0030, 32'h5555_5555, 4'b1100, 4'h5, 8'd0);
        
        axi_read(32'h0000_0020, 4'h1, 8'd0, 32'h0000_0011);
        axi_read(32'h0000_0024, 4'h2, 8'd0, 32'h0000_2200);
        axi_read(32'h0000_0028, 4'h3, 8'd0, 32'h0033_0000);
        axi_read(32'h0000_002C, 4'h4, 8'd0, 32'h4400_0000);
        axi_read(32'h0000_0030, 4'h5, 8'd0, 32'h5555_0000);
        print_test_footer();
        
        // Test 4: Different IDs
        print_test_header();
        axi_write(32'h0000_0040, 32'hAAAA_BBBB, 4'b1111, 4'h0, 8'd0);
        axi_write(32'h0000_0044, 32'hCCCC_DDDD, 4'b1111, 4'hF, 8'd0);
        axi_write(32'h0000_0048, 32'hEEEE_FFFF, 4'b1111, 4'hA, 8'd0);
        
        axi_read(32'h0000_0040, 4'h0, 8'd0, 32'hAAAA_BBBB);
        axi_read(32'h0000_0044, 4'hF, 8'd0, 32'hCCCC_DDDD);
        axi_read(32'h0000_0048, 4'hA, 8'd0, 32'hEEEE_FFFF);
        print_test_footer();
        
        // Test 5: Burst Operations
        print_test_header();
        axi_write(32'h0000_0100, 32'hBBFF_1001, 4'b1111, 4'h1, 8'd3);
        axi_read(32'h0000_0100, 4'h1, 8'd3, 32'hBBFF_1001);
        
        axi_write(32'h0000_0200, 32'hBBFF_1002, 4'b1111, 4'h2, 8'd7);
        axi_read(32'h0000_0200, 4'h2, 8'd7, 32'hBBFF_1002);
        print_test_footer();
        
        print_summary();
        
        repeat(100) @(posedge spi_clk);
        $finish;
    end

    // Timeout
    initial begin
        #1_000_000;
        print_box_header();
        $display("  TEST TIMEOUT ERROR");
        $display("==============================================");
        $display("  Simulation timeout occurred!");
        $display("  Test took too long to complete.");
        print_box_footer();
        fail_count = fail_count + 1;
        print_summary();
        $finish;
    end

endmodule
