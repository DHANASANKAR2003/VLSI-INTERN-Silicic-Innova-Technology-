////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
//                                                                                //
//      Project : Sobel Edge Detection                                            //  
//      Name    : DHANASANKAR K                                                   //
//      Code    : Design                                                          //  
//      LinkDin : www.linkedin.com/in/dhanasankar-k-23b196291                     //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
//
`timescale 1ns / 1ps

module sobel_edge_detection #(
  parameter IMG_WIDTH = 256
)(
  input wire clk,
  input wire rst,
  input wire [7:0] pixel_in,
  output reg sobel_out,
  output reg valid
);

  // Line buffers
  reg [7:0] line_buffer1 [0:IMG_WIDTH-1];
  reg [7:0] line_buffer2 [0:IMG_WIDTH-1];

  // 3x3 window registers
  reg [7:0] A00, A01, A02,
            A10, A11, A12,
            A20, A21, A22;

  // Counters
  integer col_cnt;
  integer row_cnt;

  // Gradient
  reg signed [10:0] Gx, Gy;
  reg [10:0] G;

  integer i;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      col_cnt <= 0;
      row_cnt <= 0;
      sobel_out <= 0;
      valid <= 0;

      // Clear 3x3 window
      A00 <= 0; A01 <= 0; A02 <= 0;
      A10 <= 0; A11 <= 0; A12 <= 0;
      A20 <= 0; A21 <= 0; A22 <= 0;

      // Clear line buffers using loop
      for (i = 0; i < IMG_WIDTH; i = i + 1) begin
        line_buffer1[i] <= 0;
        line_buffer2[i] <= 0;
      end
    end else begin
      // Shift window left
      A00 <= A01; A01 <= A02;
      A10 <= A11; A11 <= A12;
      A20 <= A21; A21 <= A22;

      // Update rightmost column of window
      A02 <= line_buffer2[col_cnt];
      A12 <= line_buffer1[col_cnt];
      A22 <= pixel_in;

      // Update line buffers
      line_buffer2[col_cnt] <= line_buffer1[col_cnt];
      line_buffer1[col_cnt] <= pixel_in;

      // Apply Sobel kernel after 2 rows and columns
      if (row_cnt >= 2 && col_cnt >= 2) begin
        Gx = (A00 + 2*A10 + A20) - (A02 + 2*A12 + A22);
        Gy = (A00 + 2*A01 + A02) - (A20 + 2*A21 + A22);

        // Absolute values
        if (Gx < 0) Gx = -Gx;
        if (Gy < 0) Gy = -Gy;

        G = Gx + Gy;

        sobel_out <= (G >= 100) ? 1'b1 : 1'b0;
        valid <= 1;
      end else begin
        sobel_out <= 0;
        valid <= 0;
      end

      // Update counters
      if (col_cnt == IMG_WIDTH - 1) begin
        col_cnt <= 0;
        row_cnt <= row_cnt + 1;
      end else begin
        col_cnt <= col_cnt + 1;
      end
    end
  end
endmodule
