class generator;

    // ============================================================
    // Variables
    // ============================================================
    bit random_mode;                          // 1 = random transactions, 0 = user-defined
    transaction user_queue[$];                // Queue to hold user-defined transactions
    mailbox #(transaction) gen2drv;           // Mailbox to send transactions to driver
    int num_transaction = 10;                 // Number of random transactions to generate
    event tx_done;                            // Event triggered when driver completes a transaction

    // ============================================================
    // Constructor
    // ============================================================
    function new(mailbox #(transaction) gen2drv, event e); // Constructor
        this.gen2drv    = gen2drv;            // Connect mailbox with driver
        this.random_mode = 1;                 // Default mode = random
        this.tx_done    = e;                  // Bind event for synchronization
    endfunction

    // ============================================================
    // Add a user-defined transaction
    // ============================================================
    task add_user_transaction(transaction tr); // Push custom transaction into queue
        user_queue.push_back(tr);
    endtask

    // ============================================================
    // Run generator
    // ============================================================
    task run();
      transaction tr;
      forever begin
        if (random_mode) begin
          // ---------- RANDOM TRANSACTION MODE ----------
          repeat(num_transaction) begin
            tr = new();                                // Create new transaction
            assert(tr.randomize() with { wr_en || rd_en; }); // Randomize with constraint (must be write or read)
            tr.display("GEN");                         // Display generated transaction
            gen2drv.put(tr);                           // Send transaction to driver via mailbox
            @(tx_done);                                // Wait until driver signals completion
          end
          random_mode = 0; // Switch to user mode (optional)
        end else begin
          // ---------- USER TRANSACTION MODE ----------
          if (user_queue.size() == 0) begin
            // Wait until user pushes something into queue
            @(user_queue.size() > 0);
          end
          // Process queued user transactions one by one
          while (user_queue.size() > 0) begin
            tr = user_queue.pop_front();   // Get first transaction
            tr.display("GEN");             // Display transaction
            gen2drv.put(tr);               // Send to driver
            @(tx_done);                    // Wait for completion
          end
        end
      end
    endtask
endclass
