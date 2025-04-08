//Design Code
module decoder_2to4(
  input A0,A1,EN,
  output reg D0,D1,D2,D3
);
  
always@(*)
  if(EN == 1'b1)
  {D0,D1,D2,D3} = 4'b0000;
  else
    case({A0,A1})
      
      2'b00:{D0,D1,D2,D3} = 4'b1000;
      2'b01:{D0,D1,D2,D3} = 4'b0100;
      2'b10:{D0,D1,D2,D3} = 4'b0010;
      2'b11:{D0,D1,D2,D3} = 4'b0001;
      
      default:{D0,D1,D2,D3} = 4'b0000;
    endcase
endmodule

//Testbench Code
module decoder_2to4_tb();
  reg A0,A1,EN;
  wire D0,D1,D2,D3;
  
  decoder_2to4 uut(A0,A1,EN,D0,D1,D2,D3);
  
  initial begin
    A0 = 1'b0; A1 = 1'b0; EN = 1'b1;#10;
    A0 = 1'b0; A1 = 1'b1; EN = 1'b1;#10;
    A0 = 1'b1; A1 = 1'b0; EN = 1'b1;#10;
    A0 = 1'b1; A1 = 1'b1; EN = 1'b1;#10;
    A0 = 1'b0; A1 = 1'b0; EN = 1'b0;#10;
    A0 = 1'b0; A1 = 1'b1; EN = 1'b0;#10;
    A0 = 1'b1; A1 = 1'b0; EN = 1'b0;#10;
    A0 = 1'b1; A1 = 1'b1; EN = 1'b0;#10;
    $finish;
  end
  initial begin
    $dumpfile("decoder_2to4.vcd");
    $dumpvars(1,decoder_2to4_tb);
  end
  initial begin
    $monitor("Time = %0t \t  A0 = %b A1 = %b EN = %b D0 = %b D1 = %b D2 = %b D3 = %b ",$time,A0,A1,EN,D0,D1,D2,D3);
  end
endmodule

    
