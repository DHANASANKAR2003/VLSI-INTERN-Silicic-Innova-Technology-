class driver;

    // ============================================================
    // Variables
    // ============================================================
    virtual fifo_if.Tb vif;                   // Virtual interface (connects TB -> DUT)
    mailbox #(transaction) gen2drv;           // Mailbox to receive transactions from generator
    event tx_done;                            // Event to notify generator that transaction is done

    // ============================================================
    // Constructor
    // ============================================================
    function new(virtual fifo_if.Tb vif, mailbox #(transaction) gen2drv, event e);
        this.vif      = vif;                  // Store interface handle
        this.gen2drv  = gen2drv;              // Connect generator-driver mailbox
        this.tx_done  = e;                    // Bind completion event
    endfunction

    // ============================================================
    // Main driver loop
    // ============================================================
    task run();
        transaction tr;

        forever begin
            // Get next transaction from generator
            gen2drv.get(tr);                  // Blocking call → waits for transaction

            // --- Write operation ---
            if (tr.wr_en) begin
                @(posedge vif.wr_clk);        // Wait for rising edge of write clock
                if (!vif.full && !vif.wr_rst) begin  // Only write if FIFO not full & not in reset
                    vif.data_in = tr.data;    // Drive data into FIFO
                    vif.wr_en   = 1;          // Assert write enable
                    @(posedge vif.wr_clk);    // Hold for one cycle
                    vif.wr_en   = 0;          // Deassert write enable
                    $display("[DRV] WRITE: data=%0d @ %0t", tr.data, $time);
                    ->tx_done;                // Notify generator transaction completed
                end
                else begin
                    $display("[DRV] Write skipped: FULL or RESET @ %0t", $time);
                    ->tx_done;                // Still notify completion (skip counted as done)
                end
            end

            // --- Read operation ---
            if (tr.rd_en) begin
                @(posedge vif.rd_clk);        // Wait for rising edge of read clock
                if (!vif.empty && !vif.rd_rst) begin  // Only read if FIFO not empty & not in reset
                    vif.rd_en = 1;            // Assert read enable
                    @(posedge vif.rd_clk);    // Hold for one cycle
                    vif.rd_en = 0;            // Deassert read enable
                    $display("[DRV] READ TRIGGERED @ %0t", $time);
                    ->tx_done;                // Notify generator transaction completed
                end
                else begin
                    $display("[DRV] Read skipped: EMPTY or RESET @ %0t", $time);
                    ->tx_done;                // Notify completion even if skipped
                end
            end

        end // forever
    endtask

endclass
