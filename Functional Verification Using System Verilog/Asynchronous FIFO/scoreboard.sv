class scoreboard #(parameter data_width = 8);

    // ============================================================
    // Variables
    // ============================================================
    bit [data_width-1:0] expected_q[$];      // Queue to store expected values (FIFO model)
    mailbox #(transaction) mon2scb;          // Mailbox from monitor (transactions observed)
    virtual fifo_if.Tb vif;                  // Virtual interface (not heavily used here)

    // ============================================================
    // Constructor
    // ============================================================
    function new(mailbox #(transaction) mon2scb, virtual fifo_if.Tb vif);
        this.mon2scb = mon2scb;              // Bind monitor → scoreboard mailbox
        this.vif     = vif;                  // Store interface handle
    endfunction

    // ============================================================
    // Run task
    // ============================================================
    task run();
        transaction tr;

        forever begin
            mon2scb.get(tr);                 // Blocking wait for monitor transaction

            // --- Handle Write Transaction ---
            if (tr.wr_en && !tr.rd_en) begin
                expected_q.push_back(tr.data); // Store written data in expected queue
                $display("[SCB] WRITE: expected_q = %0d", tr.data);
            end

            // --- Handle Read Transaction ---
            else if (tr.rd_en && !tr.wr_en) begin
                if (expected_q.size() > 0) begin  // Ensure something is expected
                    bit [data_width-1:0] expected_val = expected_q.pop_front();
                    if (tr.data == expected_val) begin
                        $display("[SCB][PASS] Read matched: %0d", tr.data);
                    end
                    else begin
                        $display("[SCB][FAIL] Read mismatched...Expected: %0d, Got: %0d",
                                 expected_val, tr.data);
                    end
                end
                else begin
                    $display("[SCB][WARN] Underflow: read occurred with no expected value");
                end
            end
        end
    endtask

endclass
