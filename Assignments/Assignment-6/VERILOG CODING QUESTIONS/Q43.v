43. Sequential Circuits (Flip-Flops, Counters, Shift Registers)
//Design code
module sequential_circuits(
  input  wire        clk,
  input  wire        rst,
  
  input  wire        d,
  input  wire        t,
  input  wire        j, k,
  input  wire        s, r,
  input  wire        up_down_sel,
  
  input  wire        serial_in,
  input  wire [3:0]  parallel_in,
  input  wire        load,
  input  wire        dir,
  input  wire [1:0]  mode,
  input  wire        serial_in_left,
  input  wire        serial_in_right,

  output reg         q_d,
  output wire        qn_d,
  output reg         q_t,
  output wire        qn_t,
  output reg         q_jk,
  output wire        qn_jk,
  output reg         q_sr,
  output wire        qn_sr,
  
  output reg [3:0]   up_count,
  output reg [3:0]   down_count,
  output reg [3:0]   up_down_count,
  output reg [3:0]   ring_count,

  output wire        serial_out_siso,
  output wire [3:0]  parallel_out_sipo,
  output wire        serial_out_piso,
  output reg [3:0]   parallel_out_pipo,
  output wire [3:0]  bidir_out,
  output wire [3:0]  universal_out
);

  reg [3:0] siso_reg;
  reg [3:0] sipo_reg;
  reg [3:0] piso_reg;
  reg [3:0] bidir_reg;
  reg [3:0] universal_reg;
  
  assign qn_d = ~q_d;
  assign qn_t = ~q_t;
  assign qn_jk = ~q_jk;
  assign qn_sr = ~q_sr;
  assign serial_out_siso = siso_reg[3];
  assign parallel_out_sipo = sipo_reg;
  assign serial_out_piso = piso_reg[3];
  assign bidir_out = bidir_reg;
  assign universal_out = universal_reg;

  
  always @(posedge clk or posedge rst)
    if (rst)  
      q_d <= 0;
    else      
      q_d <= d;
  
  always @(posedge clk or posedge rst)
    if (rst)      
      q_t <= 0;
    else if (t)   
      q_t <= ~q_t;
  
  always @(posedge clk or posedge rst)
    if (rst) 
      q_jk <= 0;
    else begin
      case ({j, k})
        2'b00 : q_jk <= q_jk;
        2'b01 : q_jk <= 0;
        2'b10 : q_jk <= 1;
        2'b11 : q_jk <= ~q_jk;
      endcase
    end
  
  always @(posedge clk or posedge rst)
    if (rst) 
      q_sr <= 0;
    else begin
      case ({s, r})
        2'b00 : q_sr <= q_sr;
        2'b01 : q_sr <= 0;
        2'b10 : q_sr <= 1;
        2'b11 : q_sr <= 1'bx;
      endcase
    end
  
  always @(posedge clk or posedge rst)
    if (rst)  
      up_count <= 4'b0000;
    else      
      up_count <= up_count + 1;

  always @(posedge clk or posedge rst)
    if (rst)  
      down_count <= 4'b1111;
    else      
      down_count <= down_count - 1;

  always @(posedge clk or posedge rst)
    if (rst)
      up_down_count <= 4'b0000;
    else begin
      if (up_down_sel)
        up_down_count <= up_down_count + 1;
      else
        up_down_count <= up_down_count - 1;
    end

  always @(posedge clk or posedge rst)
    if (rst)  
      ring_count <= 4'b0001;
    else      
      ring_count <= {ring_count[2:0], ring_count[3]};

  always @(posedge clk or posedge rst)
    if (rst)  
      siso_reg <= 4'b0000;
    else      
      siso_reg <= {siso_reg[2:0], serial_in};

  always @(posedge clk or posedge rst)
    if (rst)  
      sipo_reg <= 4'b0000;
    else      
      sipo_reg <= {sipo_reg[2:0], serial_in};
  
  always @(posedge clk or posedge rst)
    if (rst)        
      piso_reg <= 4'b0000;
    else if (load)  
      piso_reg <= parallel_in;
    else            
      piso_reg <= {piso_reg[2:0], 1'b0};
  
  always @(posedge clk or posedge rst)
    if (rst)        
      parallel_out_pipo <= 4'b0000;
    else if (load)  
      parallel_out_pipo <= parallel_in;

  always @(posedge clk or posedge rst)
    if (rst)  
      bidir_reg <= 4'b0000;
    else if (dir)
      bidir_reg <= {bidir_reg[2:0], serial_in};
    else
      bidir_reg <= {serial_in, bidir_reg[3:1]};
  
  always @(posedge clk or posedge rst)
    if (rst) 
      universal_reg <= 4'b0000;
    else begin
      case (mode)
        2'b00: universal_reg <= universal_reg;                         // Hold
        2'b01: universal_reg <= {serial_in_left, universal_reg[3:1]};  // Left shift
        2'b10: universal_reg <= {universal_reg[2:0], serial_in_right}; // Right shift
        2'b11: universal_reg <= parallel_in;                           // Load
      endcase
    end
endmodule

//Testbench code
`timescale 1ns/1ps
module sequential_circuits_tb;

  reg         clk;
  reg         rst;
  reg         d, t, j, k, s, r;
  reg         up_down_sel;
  reg         serial_in;
  reg  [3:0]  parallel_in;
  reg         load;
  reg         dir;
  reg  [1:0]  mode;
  reg         serial_in_left;
  reg         serial_in_right;

  wire        q_d, qn_d;
  wire        q_t, qn_t;
  wire        q_jk, qn_jk;
  wire        q_sr, qn_sr;
  wire [3:0]  up_count;
  wire [3:0]  down_count;
  wire [3:0]  up_down_count;
  wire [3:0]  ring_count;
  wire        serial_out_siso;
  wire [3:0]  parallel_out_sipo;
  wire        serial_out_piso;
  wire [3:0]  parallel_out_pipo;
  wire [3:0]  bidir_out;
  wire [3:0]  universal_out;

  // Instantiate DUT
  sequential_circuits uut (
    .clk(clk), 
    .rst(rst),
    .d(d), 
    .t(t), 
    .j(j), 
    .k(k), 
    .s(s), 
    .r(r),
    .up_down_sel(up_down_sel),
    .serial_in(serial_in),
    .parallel_in(parallel_in),
    .load(load),
    .dir(dir),
    .mode(mode),
    .serial_in_left(serial_in_left),
    .serial_in_right(serial_in_right),
    .q_d(q_d), 
    .qn_d(qn_d),
    .q_t(q_t), 
    .qn_t(qn_t),
    .q_jk(q_jk), 
    .qn_jk(qn_jk),
    .q_sr(q_sr), 
    .qn_sr(qn_sr),
    .up_count(up_count),
    .down_count(down_count),
    .up_down_count(up_down_count),
    .ring_count(ring_count),
    .serial_out_siso(serial_out_siso),
    .parallel_out_sipo(parallel_out_sipo),
    .serial_out_piso(serial_out_piso),
    .parallel_out_pipo(parallel_out_pipo),
    .bidir_out(bidir_out),
    .universal_out(universal_out)
  );

  // Clock Generation
  always #5 clk = ~clk;

  // Tabular Output Monitor
  integer cycle = 0;
  always @(posedge clk) begin
    cycle = cycle + 1;

    if (cycle == 1) begin
      $display("-----------------------------------------------------------------------------------------------------------------");
      $display("| Time(ns) | D T J K S R | Q_D Q_T Q_JK Q_SR  |   Up   Down UpDn  Ring | SISO PISO  PIPO  SIPO  |  Bidir    Univ |");
      $display("-----------------------------------------------------------------------------------------------------------------");
    end

    $display("| %8t | %b %b %b %b %b %b |  %b   %b    %b     %b  | %b  %b  %b  %b |   %b    %b   %b   %b |  %b     %b |",
             $time, d, t, j, k, s, r,
             q_d, q_t, q_jk, q_sr,
             up_count, down_count, up_down_count, ring_count,
             serial_out_siso, serial_out_piso, parallel_out_pipo, parallel_out_sipo,
             bidir_out, universal_out);
  end

  // Stimulus
  initial begin
    $dumpfile("sequential_circuits_tb.vcd");
    $dumpvars(0, sequential_circuits_tb);

    // Init
    clk = 0; rst = 1;
    d = 0; t = 0; j = 0; k = 0; s = 0; r = 0;
    up_down_sel = 0;
    serial_in = 0;
    parallel_in = 4'b1010;
    load = 0;
    dir = 0;
    mode = 2'b00;
    serial_in_left = 0;
    serial_in_right = 0;

    // Release reset
    #12 rst = 0;

    // D Flip-Flop
    d = 1; #10;
    d = 0; #10;

    // T Flip-Flop
    t = 1; #10;
    t = 0; #10;

    // JK Flip-Flop
    j = 1; k = 0; #10;
    j = 0; k = 1; #10;
    j = 1; k = 1; #10;

    // SR Flip-Flop
    s = 1; r = 0; #10;
    s = 0; r = 1; #10;
    s = 1; r = 1; #10;

    // Up/Down Counter
    up_down_sel = 1; #20;
    up_down_sel = 0; #20;

    // SISO
    serial_in = 1; #10;
    serial_in = 0; #10;
    serial_in = 1; #10;

    // SIPO
    serial_in = 1; #10;
    serial_in = 0; #10;
    serial_in = 1; #10;

    // PISO
    load = 1; parallel_in = 4'b1100; #10;
    load = 0; #40;

    // PIPO
    load = 1; parallel_in = 4'b1010; #10;
    load = 0; #10;

    // Bidirectional Shift
    dir = 1; serial_in = 1; #10;
    serial_in = 0; #10;
    dir = 0; serial_in = 1; #10;

    // Universal Shift Register
    mode = 2'b01; serial_in_left = 1; #10;  // Left shift
    mode = 2'b10; serial_in_right = 1; #10; // Right shift
    mode = 2'b11; parallel_in = 4'b1111; #10; // Load
    mode = 2'b00; #10; // Hold

    #50 
    $finish;
  end
endmodule

OUTPUT
-----------------------------------------------------------------------------------------------------------------
| Time(ns) | D T J K S R | Q_D Q_T Q_JK Q_SR  |   Up   Down UpDn  Ring | SISO PISO  PIPO  SIPO  |  Bidir    Univ |
-----------------------------------------------------------------------------------------------------------------
|     5000 | 0 0 0 0 0 0 |  0   0    0     0  | 0000  1111  0000  0001 |   0    0   0000   0000 |  0000     0000 |
|    15000 | 1 0 0 0 0 0 |  0   0    0     0  | 0000  1111  0000  0001 |   0    0   0000   0000 |  0000     0000 |
|    25000 | 0 0 0 0 0 0 |  1   0    0     0  | 0001  1110  1111  0010 |   0    0   0000   0000 |  0000     0000 |
|    35000 | 0 1 0 0 0 0 |  0   0    0     0  | 0010  1101  1110  0100 |   0    0   0000   0000 |  0000     0000 |
|    45000 | 0 0 0 0 0 0 |  0   1    0     0  | 0011  1100  1101  1000 |   0    0   0000   0000 |  0000     0000 |
|    55000 | 0 0 1 0 0 0 |  0   1    0     0  | 0100  1011  1100  0001 |   0    0   0000   0000 |  0000     0000 |
|    65000 | 0 0 0 1 0 0 |  0   1    1     0  | 0101  1010  1011  0010 |   0    0   0000   0000 |  0000     0000 |
|    75000 | 0 0 1 1 0 0 |  0   1    0     0  | 0110  1001  1010  0100 |   0    0   0000   0000 |  0000     0000 |
|    85000 | 0 0 1 1 1 0 |  0   1    1     0  | 0111  1000  1001  1000 |   0    0   0000   0000 |  0000     0000 |
|    95000 | 0 0 1 1 0 1 |  0   1    0     1  | 1000  0111  1000  0001 |   0    0   0000   0000 |  0000     0000 |
|   105000 | 0 0 1 1 1 1 |  0   1    1     0  | 1001  0110  0111  0010 |   0    0   0000   0000 |  0000     0000 |
|   115000 | 0 0 1 1 1 1 |  0   1    0     x  | 1010  0101  0110  0100 |   0    0   0000   0000 |  0000     0000 |
|   125000 | 0 0 1 1 1 1 |  0   1    1     x  | 1011  0100  0111  1000 |   0    0   0000   0000 |  0000     0000 |
|   135000 | 0 0 1 1 1 1 |  0   1    0     x  | 1100  0011  1000  0001 |   0    0   0000   0000 |  0000     0000 |
|   145000 | 0 0 1 1 1 1 |  0   1    1     x  | 1101  0010  0111  0010 |   0    0   0000   0000 |  0000     0000 |
|   155000 | 0 0 1 1 1 1 |  0   1    0     x  | 1110  0001  0110  0100 |   0    0   0000   0000 |  0000     0000 |
|   165000 | 0 0 1 1 1 1 |  0   1    1     x  | 1111  0000  0101  1000 |   0    0   0000   0001 |  1000     0000 |
|   175000 | 0 0 1 1 1 1 |  0   1    0     x  | 0000  1111  0100  0001 |   0    0   0000   0010 |  0100     0000 |
|   185000 | 0 0 1 1 1 1 |  0   1    1     x  | 0001  1110  0011  0010 |   0    0   0000   0101 |  1010     0000 |
|   195000 | 0 0 1 1 1 1 |  0   1    0     x  | 0010  1101  0010  0100 |   1    0   0000   1011 |  1101     0000 |
|   205000 | 0 0 1 1 1 1 |  0   1    1     x  | 0011  1100  0001  1000 |   0    0   0000   0110 |  0110     0000 |
|   215000 | 0 0 1 1 1 1 |  0   1    0     x  | 0100  1011  0000  0001 |   1    0   0000   1101 |  1011     0000 |
|   225000 | 0 0 1 1 1 1 |  0   1    1     x  | 0101  1010  1111  0010 |   1    1   1100   1011 |  1101     0000 |
|   235000 | 0 0 1 1 1 1 |  0   1    0     x  | 0110  1001  1110  0100 |   0    1   1100   0111 |  1110     0000 |
|   245000 | 0 0 1 1 1 1 |  0   1    1     x  | 0111  1000  1101  1000 |   1    0   1100   1111 |  1111     0000 |
|   255000 | 0 0 1 1 1 1 |  0   1    0     x  | 1000  0111  1100  0001 |   1    0   1100   1111 |  1111     0000 |
|   265000 | 0 0 1 1 1 1 |  0   1    1     x  | 1001  0110  1011  0010 |   1    0   1100   1111 |  1111     0000 |
|   275000 | 0 0 1 1 1 1 |  0   1    0     x  | 1010  0101  1010  0100 |   1    1   1010   1111 |  1111     0000 |
|   285000 | 0 0 1 1 1 1 |  0   1    1     x  | 1011  0100  1001  1000 |   1    0   1010   1111 |  1111     0000 |
|   295000 | 0 0 1 1 1 1 |  0   1    0     x  | 1100  0011  1000  0001 |   1    1   1010   1111 |  1111     0000 |
|   305000 | 0 0 1 1 1 1 |  0   1    1     x  | 1101  0010  0111  0010 |   1    0   1010   1110 |  1110     0000 |
|   315000 | 0 0 1 1 1 1 |  0   1    0     x  | 1110  0001  0110  0100 |   1    0   1010   1101 |  1111     0000 |
|   325000 | 0 0 1 1 1 1 |  0   1    1     x  | 1111  0000  0101  1000 |   1    0   1010   1011 |  1111     1000 |
|   335000 | 0 0 1 1 1 1 |  0   1    0     x  | 0000  1111  0100  0001 |   0    0   1010   0111 |  1111     0001 |
|   345000 | 0 0 1 1 1 1 |  0   1    1     x  | 0001  1110  0011  0010 |   1    0   1010   1111 |  1111     1111 |
|   355000 | 0 0 1 1 1 1 |  0   1    0     x  | 0010  1101  0010  0100 |   1    0   1010   1111 |  1111     1111 |
|   365000 | 0 0 1 1 1 1 |  0   1    1     x  | 0011  1100  0001  1000 |   1    0   1010   1111 |  1111     1111 |
|   375000 | 0 0 1 1 1 1 |  0   1    0     x  | 0100  1011  0000  0001 |   1    0   1010   1111 |  1111     1111 |
|   385000 | 0 0 1 1 1 1 |  0   1    1     x  | 0101  1010  1111  0010 |   1    0   1010   1111 |  1111     1111 |
|   395000 | 0 0 1 1 1 1 |  0   1    0     x  | 0110  1001  1110  0100 |   1    0   1010   1111 |  1111     1111 |
