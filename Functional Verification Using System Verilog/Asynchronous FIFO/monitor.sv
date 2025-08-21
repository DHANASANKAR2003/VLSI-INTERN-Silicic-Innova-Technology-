class monitor #(parameter data_width = 8);

    // ============================================================
    // Variables
    // ============================================================
    virtual fifo_if.Tb vif;                     // Virtual interface (connects to DUT signals)
    mailbox #(transaction) mon2scb;            // Mailbox to send captured transactions to scoreboard

    // ============================================================
    // Constructor
    // ============================================================
    function new(virtual fifo_if.Tb vif, mailbox #(transaction) mon2scb);
        this.vif      = vif;                   // Store interface handle
        this.mon2scb  = mon2scb;               // Connect monitor → scoreboard mailbox
    endfunction

    // ============================================================
    // Run task
    // ============================================================
    task run();
        fork
            monitor_write();                   // Parallel process → capture write activity
            monitor_read();                    // Parallel process → capture read activity
        join                                   // Both run forever
    endtask

    // ============================================================
    // Monitor write transactions
    // ============================================================
    task monitor_write();
        transaction tr;

        forever begin
            @(posedge vif.wr_clk);             // Sample on write clock edge
            if (vif.wr_en && !vif.full) begin  // Only capture valid writes
                tr = new();                    
                tr.wr_en = 1;                  // Mark this as a write
                tr.data   = vif.data_in;       // Capture data being written
                mon2scb.put(tr.copy());        // Send a *copy* to scoreboard
                $display("[MON] Captured WRITE: data = %0d", tr.data);
            end
        end
    endtask

    // ============================================================
    // Monitor read transactions
    // ============================================================
    task monitor_read();
        transaction tr;

        forever begin
            @(posedge vif.rd_clk);             // Sample on read clock edge
            if (vif.rd_en && !vif.empty) begin // Only capture valid reads
                @(posedge vif.rd_clk);         // Optional: wait 1 more cycle (data stable)
                tr = new();
                tr.rd_en = 1;                  // Mark this as a read
                tr.data  = vif.data_out;       // Capture data read from FIFO
                mon2scb.put(tr.copy());        // Send captured transaction to scoreboard
                $display("[MON] Captured READ: data = %0d", tr.data);
            end
        end
    endtask

endclass
