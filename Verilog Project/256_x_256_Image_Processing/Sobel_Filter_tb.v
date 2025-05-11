////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
//                                                                                //
//      Project : Sobel Edge Detection                                            //  
//      Name    : DHANASANKAR K                                                   //
//      Code    : Test Bench                                                      //  
//      LinkDin : www.linkedin.com/in/dhanasankar-k-23b196291                     //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module testbench;

    // Inputs to the sobel_edge_detection module
    reg clk;
    reg rst;
    reg [7:0] pixel_in;
    wire sobel_out;

    // File handle
    integer outfile;

    // Instantiate the sobel_edge_detection module
    sobel_edge_detection sobel_inst (
        .clk(clk),
        .rst(rst),
        .pixel_in(pixel_in),
        .sobel_out(sobel_out)
    );

    // Clock generation: 100MHz (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus block
    initial begin
        // Open the output file
        outfile = $fopen("sobel_output.txt", "w");
        if (outfile == 0) begin
            $display("ERROR: Could not open sobel_output.txt");
            $finish;
        end

        // Initialize signals
        rst = 1;
        pixel_in = 8'd0;
        #20 rst = 0;
       
	// You Can Add a 65536 pixel values
        // Sample pixel stream (can be replaced with full image pixels)
        
//Example Pixel Value

// pixel_in = 8'd53; #10;
// pixel_in = 8'd33; #10;
// pixel_in = 8'd24; #10;
// pixel_in = 8'd19; #10;
// pixel_in = 8'd18; #10;
// pixel_in = 8'd16; #10;


        // You can add more actual frame pixels or a loop for test pattern
        for (integer i = 0; i < 65535; i = i + 1) begin
            pixel_in = i[7:0];
            #10;
        end

        // Wait a bit and finish
        #20000;
        $fclose(outfile);
        $finish;
    end

    // VCD waveform dump
    initial begin
        $dumpfile("sobel_edge_detection.vcd");
        $dumpvars(0, testbench);
    end

    // Log output per clock
    always @(posedge clk) begin
        if (!rst) begin
            $fwrite(outfile, "Sobel Output: %b\n", sobel_out);
        end
    end
endmodule
