//Design Code
module encoder_8to3(
  input [7:0]D,
  output reg [2:0]Y
);
  
  always@(*)
    begin
      case(D)
        8'b00000001: Y = 3'b111;
        8'b00000010: Y = 3'b110;
        8'b00000100: Y = 3'b101;
        8'b00001000: Y = 3'b100;
        8'b00010000: Y = 3'b001;
        8'b00100000: Y = 3'b000;
        8'b01000000: Y = 3'b001;
        8'b10000000: Y = 3'b000;
        default: Y = 3'bxxx;
      endcase
    end
endmodule

//Testbench code
module encoder_8to3_tb;
  reg [7:0]D;
  wire [2:0]Y;
  
  encoder_8to3 uut(D,Y);
  
  initial begin
    D = 8'b10000000;#10;
    D = 8'b01000000;#10;
    D = 8'b00100000;#10;
    D = 8'b00010000;#10;
    D = 8'b00001000;#10;
    D = 8'b00000100;#10;
    D = 8'b00000010;#10;
    D = 8'b00000001;#10;
    $finish;
  end
  initial begin
    $dumpfile("encoder_8to3.vcd");
    $dumpvars(1,encoder_8to3_tb);
  end
  initial begin
    $monitor("Time = %0t \t D = %b Y = %b ",$time,D,Y);
  end
endmodule
    
