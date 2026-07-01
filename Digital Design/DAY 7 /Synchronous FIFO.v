//Design Code
module synchronous_fifo #(
  parameter DEPTH = 8,
  parameter DATA_WIDTH = 8)(
  input clk,
  input rst_n,
  input w_en,
  input r_en,
  input [DATA_WIDTH-1:0] data_in,
  output reg [DATA_WIDTH-1:0] data_out,
  output full,
  output empty
);

  localparam PTR_WIDTH = $clog2(DEPTH);

  reg [DATA_WIDTH-1:0] fifo [0:DEPTH-1];
  reg [PTR_WIDTH-1:0] w_ptr, r_ptr;
  reg [PTR_WIDTH:0] count; 


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      w_ptr <= 0;
    end 
    else if (w_en && !full) begin
      fifo[w_ptr] <= data_in;
      w_ptr <= w_ptr + 1;
    end
  end


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      r_ptr <= 0;
      data_out <= 0;
    end 
    else if (r_en && !empty) begin
      data_out <= fifo[r_ptr];
      r_ptr <= r_ptr + 1;
    end
  end


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= 0;
    end 
    else 
      begin
        case ({w_en && !full, r_en && !empty})
          2'b10: count <= count + 1;
          2'b01: count <= count - 1; 
          default: count <= count; 
        endcase
    end
  end

  
  assign full = (count == DEPTH);
  assign empty = (count == 0);

endmodule

//Testbench Code
module tb_fifo;
  parameter DEPTH = 8;
  parameter DATA_WIDTH = 8;
  reg clk, rst_n;
  reg w_en, r_en;
  reg [DATA_WIDTH-1:0] data_in;
  wire [DATA_WIDTH-1:0] data_out;
  wire full, empty;
  synchronous_fifo #(DEPTH, DATA_WIDTH) dut (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(w_en),
    .r_en(r_en),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
  );
  initial begin
    $dumpfile("synchronous_fifo");
    $dumpvars(1,tb_fifo);
  end

  always #5 clk = ~clk;
  initial begin
    clk = 0;
    rst_n = 0;
    w_en = 0;
    r_en = 0;
    data_in = 0;

  
    #10 rst_n = 1;

    $display("Writing to FIFO...");
    repeat (DEPTH) begin
      @(posedge clk);
      w_en = 1;
      data_in = $random % 256;
      $display("WRITE: data_in = %0d \t| full = %b | empty = %b", data_in, full, empty);
    end
    @(posedge clk); 
    w_en = 0;
    if (full)
      $display("FIFO is FULL as expected.");
    else
      $display("ERROR: FIFO should be FULL!");

    $display("Reading from FIFO...");
    repeat (DEPTH) begin
      @(posedge clk);
      r_en = 1;
      $display("READ: data_out = %0d \t| full = %b | empty = %b", data_out, full, empty);
    end
    @(posedge clk); 
    r_en = 0;
    if (empty)
      $display("FIFO is EMPTY as expected.");
    else
      $display("ERROR: FIFO should be EMPTY!");

    #20;
    $display("TEST FINISHED.");
    $finish;
  end

endmodule
