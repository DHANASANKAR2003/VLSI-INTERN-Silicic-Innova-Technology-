
// Code your design 
module ram(
    input clk,
    input write_enable,
    input [9:0]address,
    input [7:0]data_in,
    output reg [7:0]data_out
);

reg [7:0]ram_block[0:1023];

always @(posedge clk) begin
        if(write_enable)
            ram_block[address] <= data_in;
        else
            data_out <= ram_block[address];
end

endmodule     
// Code your testbench here
// or browse Examples
module ram_tb;

    reg clk;
    reg write_enable;
    reg [9:0] address;
    reg [7:0] data_in;
    wire [7:0] data_out;

    reg [7:0] expected_data;

    // Instantiate DUT
    ram uut (
        .clk(clk),
        .write_enable(write_enable),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock generation
    always #10 clk = ~clk;

    // Dump VCD
    initial begin
        $dumpfile("ram_tb.vcd");
        $dumpvars(0, ram_tb);
    end

    // Monitor
    initial begin
        $monitor("Time = %0t \t CLK = %b WRITE_ENABLE = %b ADDRESS = %d DATA_IN = %h DATA_OUT = %h",
                 $time, clk, write_enable, address, data_in, data_out);
    end

    // Stimulus + Self-checking
    initial begin
        // Initialize
        clk = 0;
        write_enable = 0;
        data_in = 0;
        address = 0;

        // --- Write 1 ---
        #20;
        write_enable = 1;
        data_in = 8'h56;
        address = 55;
        expected_data = 8'h56;
        #20;

        // --- Read 1 ---
        write_enable = 0;
        #20;
        if (data_out === expected_data)
            $display("PASS: Read 0x%h from address %0d", data_out, address);
        else
            $display("FAIL: Read 0x%h from address %0d, expected 0x%h", data_out, address, expected_data);

        // --- Write 2 ---
        write_enable = 1;
        data_in = 8'h36;
        address = 55;
        expected_data = 8'h36;
        #20;

        // --- Read 2 ---
        write_enable = 0;
        #20;
        if (data_out === expected_data)
            $display("PASS: Read 0x%h from address %0d", data_out, address);
        else
            $display("FAIL: Read 0x%h from address %0d, expected 0x%h", data_out, address, expected_data);

        $finish();
    end

endmodule
