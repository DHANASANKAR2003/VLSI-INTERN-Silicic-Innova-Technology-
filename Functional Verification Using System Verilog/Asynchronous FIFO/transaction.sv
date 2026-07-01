class transaction;

    // ============================================================
    // Variables
    // ============================================================
    rand bit [7:0] data;          // Randomizable data for read/write
    rand bit       wr_en;         // Randomizable Write enable
    rand bit       rd_en;         // Randomizable Read enable
    bit [7:0]      expected_data; // Expected data for verification (from scoreboard)

    // ============================================================
    // Constructor
    // ============================================================
    function new();                // Constructor initializes default values
        data          = 8'h00;     // Initialize data
        wr_en         = 0;         // Initialize write enable
        rd_en         = 0;         // Initialize read enable
        expected_data = 8'h00;     // Initialize expected data
    endfunction

    // ============================================================
    // Display transaction
    // ============================================================
    function void display(string tag = "");  // Print transaction for debug
        $display("[%0s] TX: wr_en = %0b | rd_en = %0b | data = 0x%0h | expected = 0x%0h",
                 tag, wr_en, rd_en, data, expected_data);
    endfunction

    // ============================================================
    // Copy transaction
    // ============================================================
    function transaction copy();   // Create deep copy of transaction
        transaction t = new();     // Allocate new transaction object
        t.data          = this.data;          // Copy data
        t.wr_en         = this.wr_en;         // Copy write enable
        t.rd_en         = this.rd_en;         // Copy read enable
        t.expected_data = this.expected_data; // Copy expected data
        return t;                 // Return the copy
    endfunction

    // ============================================================
    // Compare transactions
    // ============================================================
    function bit compare(transaction t);  // Compare two transactions
        return (this.data == t.data);     // Only compares "data" field
    endfunction

endclass
