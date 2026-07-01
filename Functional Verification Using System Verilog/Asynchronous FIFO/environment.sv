class environment #(int data_width = 8);

    // ============================================================
    // Events
    // ============================================================
    event tx_done;                            // Synchronization event between generator & driver

    // ============================================================
    // Components
    // ============================================================
    generator        gen;                     // Stimulus generator
    driver           drv;                     // Drives DUT using vif
    monitor #(data_width) mon;                // Observes DUT activity
    scoreboard #(data_width) scb;             // Checks DUT output against reference model

    // ============================================================
    // Mailboxes
    // ============================================================
    mailbox #(transaction) gen2drv;           // Generator → Driver communication
    mailbox #(transaction) mon2scb;           // Monitor → Scoreboard communication

    // ============================================================
    // Virtual Interface
    // ============================================================
    virtual fifo_if.Tb vif;                   // DUT connection for all components

    // ============================================================
    // Constructor
    // ============================================================
    function new(virtual fifo_if.Tb vif);
        this.vif = vif;                       // Store interface handle

        // --- Create typed mailboxes ---
        gen2drv  = new();                     // For generator-driver handshake
        mon2scb  = new();                     // For monitor-scoreboard transfer
       
        // --- Instantiate components ---
        gen = new(gen2drv, tx_done);          // Pass mailbox + sync event
        drv = new(vif, gen2drv, tx_done);     // Pass vif + mailbox + sync event
        mon = new(vif, mon2scb);              // Pass vif + monitor → scoreboard mailbox
        scb = new(mon2scb, vif);              // Pass monitor → scoreboard mailbox + vif
    endfunction

    // ============================================================
    // Run environment
    // ============================================================
    task run();
        $display("[ENV] Starting environment...");
        fork
            gen.run();                        // Start generator
            drv.run();                        // Start driver
            mon.run();                        // Start monitor
            scb.run();                        // Start scoreboard
        join_none;                            // Let all run in parallel, don't block simulation
    endtask

endclass
