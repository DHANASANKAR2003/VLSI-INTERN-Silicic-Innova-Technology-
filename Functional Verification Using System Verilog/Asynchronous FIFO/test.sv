program automatic test(fifo_if.Tb intf);

    environment #(8) env;                     // DUT environment instance
    transaction tr;                           // Reusable transaction handle

    // ============================================================
    // Utility: reset FIFO
    // ============================================================
    task automatic apply_reset();
        env.gen.random_mode = 0;              // Disable random mode during reset
        intf.wr_rst  = 1;                     // Assert write reset
        intf.rd_rst  = 1;                     // Assert read reset
        intf.wr_en   = 0;                     // Disable write enable
        intf.rd_en   = 0;                     // Disable read enable
        intf.data_in = 0;                     // Clear data bus
        #5;
        intf.wr_rst = 0;                      // Deassert write reset
        intf.rd_rst = 0;                      // Deassert read reset
        #5;
        $display("[TEST] Reset deasserted at %0t", $time);
    endtask


    // ============================================================
    // 1. Reset test
    // ============================================================
    task automatic reset_test();
        $display("\n=== RESET TEST ===");
        env.gen.random_mode = 0;              // Force deterministic behavior
        apply_reset();                        // Apply reset sequence
    endtask


    // ============================================================
    // 2. One write then read
    // ============================================================
    task automatic one_write_read();
        apply_reset();                        // Clean start

        $display("\n=== ONE WRITE & READ TEST ===");

        // --- Write transaction ---
        tr = new();                           // Create transaction
        tr.data   = 8'hA5;                    // Test data
        tr.wr_en  = 1;                        // Enable write
        tr.rd_en  = 0;                        // Disable read
        env.gen.add_user_transaction(tr);     // Send to generator
        @(env.tx_done);                       // Wait for completion

        @(posedge env.vif.rd_clk);            // Sync with read clock

        // --- Read transaction ---
        tr = new();
        tr.wr_en  = 0;
        tr.rd_en  = 1;                        // Enable read
        env.gen.add_user_transaction(tr);
        @(env.tx_done);                       // Wait for completion
    endtask


    // ============================================================
    // 3. Multiple writes and reads
    // ============================================================
    task automatic multi_rw();
        apply_reset();
        $display("\n=== MULTI WRITE & READ TEST ===");

        // Write 4 values
        for (int i = 0; i < 4; i++) begin
            tr = new();
            tr.data   = i;                    // Data = 0,1,2,3
            tr.wr_en  = 1;
            tr.rd_en  = 0;
            env.gen.add_user_transaction(tr);
            @(env.tx_done);                   // Wait each write done
            @(posedge env.vif.wr_clk);        // Sync with write clock
        end
        #15;

        // Read 4 values
        for (int i = 0; i < 4; i++) begin
            tr = new();
            tr.wr_en  = 0;
            tr.rd_en  = 1;
            env.gen.add_user_transaction(tr);
            @(env.tx_done);                   // Wait each read done
            @(posedge env.vif.rd_clk);        // Sync with read clock
        end
      
    endtask


    // ============================================================
    // 4. Overflow test
    // ============================================================
    task automatic overflow_test();
        $display("\n=== OVERFLOW TEST ===");

        for (int i = 0; i < 20; i++) begin    // depth=16, write >16 to cause overflow
            tr = new();
            tr.data   = i;
            tr.wr_en  = 1;
            tr.rd_en  = 0;
            env.gen.add_user_transaction(tr);
            @(env.tx_done);
            @(posedge env.vif.wr_clk);
        end
        env.gen.random_mode = 0;
    endtask


    // ============================================================
    // 5. Underflow test
    // ============================================================
    task automatic underflow_test();
        $display("\n=== UNDERFLOW TEST ===");

        for (int i = 0; i < 5; i++) begin     // Read without prior writes
            tr = new();
            tr.wr_en  = 0;
            tr.rd_en  = 1;
            env.gen.add_user_transaction(tr);
            @(env.tx_done);
            @(posedge env.vif.rd_clk);
        end
        env.gen.random_mode = 0;
    endtask


    // ============================================================
    // 6. Random read/write
    // ============================================================
    task automatic random_test();
        $display("\n=== RANDOM WRITE/READ TEST ===");
        env.gen.random_mode     = 1;          // Enable random mode in generator
        env.gen.num_transaction = 20;         // Generate 20 random transactions
    endtask


    // ============================================================
    // 7. Wrap-around test
    // ============================================================
    task automatic wraparound_test();
        $display("\n=== WRAP-AROUND TEST ===");

        for (int i = 0; i < 40; i++) begin    // > 2*depth, tests pointer wrap-around
            tr = new();
            tr.data   = i;
            tr.wr_en  = 1;
            tr.rd_en  = (i % 2);              // Alternate read/write
            env.gen.add_user_transaction(tr);
            @(env.tx_done);
            @(posedge env.vif.wr_clk);
            @(posedge env.vif.rd_clk);
        end
        env.gen.random_mode = 0;
    endtask


    // ============================================================
    // 8. Reset during operation
    // ============================================================
    task automatic mid_reset_test();
        $display("\n=== MID RESET TEST ===");
        fork
            begin
                for (int i = 0; i < 10; i++) begin
                    tr = new();
                    tr.data   = i;
                    tr.wr_en  = 1;
                    tr.rd_en  = (i % 2);      // Alternate
                    env.gen.add_user_transaction(tr);
                    @(env.tx_done);
                    @(posedge env.vif.wr_clk);
                    @(posedge env.vif.rd_clk);
                end
                env.gen.random_mode = 0;
            end
            begin
                #50 apply_reset();            // Reset while operations are ongoing
            end
        join
    endtask


    // ============================================================
    // 9. Simultaneous write & read
    // ============================================================
    task automatic sim_wr_rd();
        $display("\n=== SIMULTANEOUS WRITE & READ TEST ===");

        for (int i = 0; i < 10; i++) begin
            tr = new();
            tr.data   = i;
            tr.wr_en  = 1;
            tr.rd_en  = 1;                    // Both write & read enabled
            env.gen.add_user_transaction(tr);
            @(env.tx_done);
            @(posedge env.vif.wr_clk);
            @(posedge env.vif.rd_clk);
        end
        env.gen.random_mode = 0;
    endtask


    // ============================================================
    // Main initial block
    // ============================================================
    initial begin
        env = new(intf);                      // Instantiate environment with interface

        env.run();                            // Start environment (gen, drv, mon, scb)

        // Run each directed & random test one by one
        reset_test();          #100;
        one_write_read();      #200;
        multi_rw();            #300;
        overflow_test();       #500;
        underflow_test();      #300;
        random_test();         #500;
        wraparound_test();     #800;
        mid_reset_test();      #500;
        sim_wr_rd();           #400;

        $display("//TESTS COMPLETED");
        $finish;                             // End simulation
    end

endprogram
