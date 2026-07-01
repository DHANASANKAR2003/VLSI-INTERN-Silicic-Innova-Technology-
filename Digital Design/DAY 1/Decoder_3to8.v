//Design Code
module decoder_3to8(
  input A0,A1,A2,EN,
  output reg D0,D1,D2,D3,D4,D5,D6,D7
);
  
always@(*)
  if(EN == 1'b0)
  {D0,D1,D2,D3,D4,D5,D6,D7} = 8'b00000000;
  else
    case({A0,A1,A2})
      
      3'b000:{D0,D1,D2,D3,D4,D5,D6,D7} = 8'b10000000;
      3'b001:{D0,D1,D2,D3,D4,D5,D6,D7} = 8'b01000000;
      3'b010:{D0,D1,D2,D3,D4,D5,D6,D7} = 8'b00100000;
      3'b011:{D0,D1,D2,D3,D4,D5,D6,D7} = 8'b00010000;
      3'b100:{D0,D1,D2,D3,D4,D5,D6,D7} = 8'b00001000;
      3'b101:{D0,D1,D2,D3,D4,D5,D6,D7} = 8'b00000100;
      3'b110:{D0,D1,D2,D3,D4,D5,D6,D7} = 8'b00000010;
      3'b111:{D0,D1,D2,D3,D4,D5,D6,D7} = 8'b00000001;
      
      default:{D0,D1,D2,D3,D4,D5,D6,D7} = 8'b00000000;
    endcase
endmodule

module decoder_3to8_tb();
  reg A0,A1,A2,EN;
  wire D0,D1,D2,D3,D4,D5,D6,D7;
  
  decoder_3to8 uut(A0,A1,A2,EN,D0,D1,D2,D3,D4,D5,D6,D7);
  
  initial begin
    A0 = 1'b0; A1 = 1'b0; A2 = 1'b0; EN = 1'b0;#10;
    A0 = 1'b0; A1 = 1'b0; A2 = 1'b1; EN = 1'b0;#10;
    A0 = 1'b0; A1 = 1'b1; A2 = 1'b0; EN = 1'b0;#10;
    A0 = 1'b0; A1 = 1'b1; A2 = 1'b1; EN = 1'b0;#10;
    A0 = 1'b1; A1 = 1'b0; A2 = 1'b0; EN = 1'b0;#10;
    A0 = 1'b1; A1 = 1'b0; A2 = 1'b1; EN = 1'b0;#10;
    A0 = 1'b1; A1 = 1'b1; A2 = 1'b0; EN = 1'b0;#10;
    A0 = 1'b1; A1 = 1'b1; A2 = 1'b1; EN = 1'b0;#10;
    
    A0 = 1'b0; A1 = 1'b0; A2 = 1'b0; EN = 1'b1;#10;
    A0 = 1'b0; A1 = 1'b0; A2 = 1'b1; EN = 1'b1;#10;
    A0 = 1'b0; A1 = 1'b1; A2 = 1'b0; EN = 1'b1;#10;
    A0 = 1'b0; A1 = 1'b1; A2 = 1'b1; EN = 1'b1;#10;
    A0 = 1'b1; A1 = 1'b0; A2 = 1'b0; EN = 1'b1;#10;
    A0 = 1'b1; A1 = 1'b0; A2 = 1'b1; EN = 1'b1;#10;
    A0 = 1'b1; A1 = 1'b1; A2 = 1'b0; EN = 1'b1;#10;
    A0 = 1'b1; A1 = 1'b1; A2 = 1'b1; EN = 1'b1;#10;
    $finish;
  end
  initial begin
    $dumpfile("decoder_2to4.vcd");
    $dumpvars(0,decoder_2to4_tb);
  end
  initial begin
    $monitor("Time = %0t \t  A0 = %b A1 = %b A2 = %b EN = %b D0 = %b D1 = %b D2 = %b D3 = %b D4 = %b D5 = %b D6 = %b D7 = %b ",$time,A0,A1,A2,EN,D0,D1,D2,D3,D4,D5,D6,D7);
  end
endmodule
