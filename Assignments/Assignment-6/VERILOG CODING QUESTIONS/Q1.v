1. Basic Combinational Circuits (MUX, DEMUX, ENCODER, DECODER, etc.)

=========================MUX=========================
//Design Code 
module MUX_4TO_1(
  input [3:0]data_in,
  input [1:0]sel,
  output wire out
);
  assign out = data_in[sel];
endmodule 

//tetbench code
module MUX_4_TO_1_tb;
  reg [3:0]data_in;
  reg [1:0]sel;
  wire out;
  
  MUX_4TO_1 dut(
    .data_in(data_in),
    .sel(sel),
    .out(out));
  
  initial begin
    data_in = 4'b1010;
    sel = 2'b00;#10
    
    sel = 2'b00;#10;
    $display("Time = %0t SEL = %b Input = %b (Expected = %b) Output = %b",$time,sel,data_in,data_in[0],out);
    
    sel = 2'b01;#10;
    $display("Time = %0t SEL = %b Input = %b (Expected = %b) Output = %b",$time,sel,data_in,data_in[1],out);
    
    sel = 2'b10;#10;
    $display("Time = %0t SEL = %b Input = %b (Expected = %b) Output = %b",$time,sel,data_in,data_in[2],out);
    
    sel = 2'b11;#10;
    $display("Time = %0t SEL = %b Input = %b (Expected = %b) Output = %b",$time,sel,data_in,data_in[3],out);
    
    data_in = 4'b1100;
    
    sel = 2'b00;#10;
    $display("Time = %0t SEL = %b Input = %b (Expected = %b) Output = %b",$time,sel,data_in,data_in[0],out);
    
    sel = 2'b01;#10;
    $display("Time = %0t SEL = %b Input = %b (Expected = %b) Output = %b",$time,sel,data_in,data_in[1],out);
    
    sel = 2'b10;#10;
    $display("Time = %0t SEL = %b Input = %b (Expected = %b) Output = %b",$time,sel,data_in,data_in[2],out);
    
    sel = 2'b11;#10;
    $display("Time = %0t SEL = %b Input = %b (Expected = %b) Output = %b",$time,sel,data_in,data_in[3],out);
  end
 
endmodule

OUTPUT
Time = 20 SEL = 00 Input = 1010 (Expected = 0) Output = 0
Time = 30 SEL = 01 Input = 1010 (Expected = 1) Output = 1
Time = 40 SEL = 10 Input = 1010 (Expected = 0) Output = 0
Time = 50 SEL = 11 Input = 1010 (Expected = 1) Output = 1
Time = 60 SEL = 00 Input = 1100 (Expected = 0) Output = 0
Time = 70 SEL = 01 Input = 1100 (Expected = 0) Output = 0
Time = 80 SEL = 10 Input = 1100 (Expected = 1) Output = 1
Time = 90 SEL = 11 Input = 1100 (Expected = 1) Output = 1

=========================DEMUX=========================
//Design Code 
module MUX_4TO_1(
  input data_in,
  input [1:0]sel,
  output reg [3:0]out
);
  always@(*)
    begin 
      out = 4'b0000;
      out[sel] = data_in;
    end
endmodule 

//tetbench code
module MUX_4_TO_1_tb;
  reg data_in;
  reg [1:0]sel;
  wire [3:0]out;
  
  MUX_4TO_1 dut(
    .data_in(data_in),
    .sel(sel),
    .out(out));
  
  initial begin
    data_in = 1'b1;#10
    
    sel = 2'b00;#10;
    $display("Time = %0t SEL = %b Input = %b (Expected = 0001) Output = %b",$time,sel,data_in,out);
    
    sel = 2'b01;#10;
    $display("Time = %0t SEL = %b Input = %b (Expected = 0010) Output = %b",$time,sel,data_in,out);
    
    sel = 2'b10;#10;
    $display("Time = %0t SEL = %b Input = %b (Expected = 0100) Output = %b",$time,sel,data_in,out);
    
    sel = 2'b11;#10;
    $display("Time = %0t SEL = %b Input = %b (Expected = 1000) Output = %b",$time,sel,data_in,out);
    
    data_in = 1'b0;
    
    sel = 2'b00;#10;
    $display("Time = %0t SEL = %b Input = %b (Expected = 0001) Output = %b",$time,sel,data_in,out);
    
    sel = 2'b01;#10;
    $display("Time = %0t SEL = %b Input = %b (Expected = 0010) Output = %b",$time,sel,data_in,out);
    
    sel = 2'b10;#10;
    $display("Time = %0t SEL = %b Input = %b (Expected = 0100) Output = %b",$time,sel,data_in,out);
    
    sel = 2'b11;#10;
    $display("Time = %0t SEL = %b Input = %b (Expected = 1000) Output = %b",$time,sel,data_in,out);
  end
 
endmodule

OUTPUT
Time = 20 SEL = 00 Input = 1 (Expected = 0001) Output = 0001
Time = 30 SEL = 01 Input = 1 (Expected = 0010) Output = 0010
Time = 40 SEL = 10 Input = 1 (Expected = 0100) Output = 0100
Time = 50 SEL = 11 Input = 1 (Expected = 1000) Output = 1000
Time = 60 SEL = 00 Input = 0 (Expected = 0001) Output = 0000
Time = 70 SEL = 01 Input = 0 (Expected = 0010) Output = 0000
Time = 80 SEL = 10 Input = 0 (Expected = 0100) Output = 0000
Time = 90 SEL = 11 Input = 0 (Expected = 1000) Output = 0000

=========================DECODER=========================
//Design Code 
module DECODER_4_TO_2(
  input [1:0]data_in,
  input en,
  output reg [3:0]out
);
  
  always@(*)
    begin
      if(en)
        begin
          case(data_in)
            2'b00 : out = 4'b0001;
            2'b01 : out = 4'b0010;
            2'b10 : out = 4'b0100;
            2'b11 : out = 4'b1000;
            default : out = 4'b0000;
          endcase
        end
      else
        out = 4'b0000;
    end
endmodule

//tetbench code
module DECODER_4_TO_2_tb;
  reg [1:0]data_in;
  reg en;
  wire [3:0]out;
  
  DECODER_4_TO_2 dut(
    .data_in(data_in),
    .en(en),
    .out(out));
  
  initial begin
    en= 1'b0;#10;
    data_in = 2'b01;#10;
 
    $display("Time = %0t ENABLE = %b Input = %b (Expected = 0000) Output = %b",$time,en,data_in,out);
    
    en= 1'b1;#10;
    data_in = 2'b00;#10;
    $display("Time = %0t ENABLE = %b Input = %b (Expected = 0001) Output = %b",$time,en,data_in,out);
    
    data_in = 4'b01;#10;
    $display("Time = %0t ENABLE = %b Input = %b (Expected = 0010) Output = %b",$time,en,data_in,out);
    
    data_in = 4'b10;#10;
    $display("Time = %0t ENABLE = %b Input = %b (Expected = 0100) Output = %b",$time,en,data_in,out);
    
    data_in = 4'b11;#10;
    $display("Time = %0t ENABLE = %b Input = %b (Expected = 1000) Output = %b",$time,en,data_in,out);
    
  end
 
endmodule

OUTPUT
Time = 20 ENABLE = 0 Input = 01 (Expected = 0000) Output = 0000
Time = 40 ENABLE = 1 Input = 00 (Expected = 0001) Output = 0001
Time = 50 ENABLE = 1 Input = 01 (Expected = 0010) Output = 0010
Time = 60 ENABLE = 1 Input = 10 (Expected = 0100) Output = 0100
Time = 70 ENABLE = 1 Input = 11 (Expected = 1000) Output = 1000

=========================ENCODER=========================
//Design Code 
module ENCODER_4_TO_2(
  input [3:0]data_in,
  input en,
  output reg [1:0]out
);
  
  always@(*)
    begin
      if(en)
        begin
          case (data_in)
            4'b0001: out = 2'b00;
            4'b0010: out = 2'b01;
            4'b0100: out = 2'b10;
            4'b1000: out = 2'b11;
            default: out = 2'b00;  
          endcase
        end
      else
        out = 2'b00;
    end
endmodule

//tetbench code
module ENCODER_4_TO_2_tb;
  reg [3:0]data_in;
  reg en;
  wire [1:0]out;
  
  ENCODER_4_TO_2 dut(
    .data_in(data_in),
    .en(en),
    .out(out));
  
  initial begin
    en= 1'b0;#10;
    data_in = 4'b0001;#10;
 
    $display("Time = %0t ENABLE = %b Input = %b (Expected = 00) Output = %b",$time,en,data_in,out);
    
    en= 1'b1;#10;
    data_in = 4'b0001;#10;
    $display("Time = %0t ENABLE = %b Input = %b (Expected = 00) Output = %b",$time,en,data_in,out);
    
    data_in = 4'b0010;#10;
    $display("Time = %0t ENABLE = %b Input = %b (Expected = 01) Output = %b",$time,en,data_in,out);
    
    data_in = 4'b0100;#10;
    $display("Time = %0t ENABLE = %b Input = %b (Expected = 10) Output = %b",$time,en,data_in,out);
    
    data_in = 4'b1000;#10;
    $display("Time = %0t ENABLE = %b Input = %b (Expected = 11) Output = %b",$time,en,data_in,out);
    
  end
endmodule

OUTPUT
Time = 20 ENABLE = 0 Input = 0001 (Expected = 00) Output = 00
Time = 40 ENABLE = 1 Input = 0001 (Expected = 00) Output = 00
Time = 50 ENABLE = 1 Input = 0010 (Expected = 01) Output = 01
Time = 60 ENABLE = 1 Input = 0100 (Expected = 10) Output = 10
Time = 70 ENABLE = 1 Input = 1000 (Expected = 11) Output = 11

