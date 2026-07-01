//Design Code
module encoder_4to2(
  input [3:0]D,
  output reg [1:0]Y
);
  
  always@(*)
    begin
      case(D)
        4'b0001: Y = 2'b11;
        4'b0010: Y = 2'b10;
        4'b0100: Y = 2'b01;
        4'b1000: Y = 2'b00;
        default: Y = 2'bxx;
      endcase
    end
endmodule

//Testbench code
module encoder_4to2_tb;
  reg [3:0]D;
  wire [1:0]Y;
  
  encoder_4to2 uut(D,Y);
  
  initial begin
    D = 4'b1000;#10;
    D = 4'b0100;#10;
    D = 4'b0010;#10;
    D = 4'b0001;#10;
    $finish;
  end
  initial begin
    $dumpfile("encoder_4to2.vcd");
    $dumpvars(1,encoder_4to2_tb);
  end
  initial begin
    $monitor("Time = %0t \t D = %b Y = %b ",$time,D,Y);
  end
endmodule
    
