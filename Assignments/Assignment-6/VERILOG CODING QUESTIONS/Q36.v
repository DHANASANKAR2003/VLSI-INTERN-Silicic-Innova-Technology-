36. Implement a 4-bit multiply-accumulate unit (MAC).
//Design code
module mac_4bit(
  input [3:0]A,
  input [3:0]B,
  input [7:0]ACC,
  output reg[7:0]mac_out
);
  
  always@(*)
    begin
      mac_out = ACC + (A * B);
    end
endmodule
//Testbench code
module mac_4bit_tb;
  reg [3:0]A,B;
  reg [7:0]ACC ;
  wire [7:0]mac_out;
  
  mac_4bit uut(
    A,
    B,
    ACC,
    mac_out);
  initial begin
    A = 4'b0011;
    B = 4'b1010;
    ACC = 8'd10;#10;
    
    $display("Time = %0t A = %d B = %d ACC = %d MAC OUT = %d",$time,A,B,ACC,mac_out);
    
    A = 4'b1011;
    B = 4'b1010;
    ACC = 8'd10;#10;
    
    $display("Time = %0t A = %d B = %d ACC = %d MAC OUT = %d",$time,A,B,ACC,mac_out);
    
    A = 4'b0111;
    B = 4'b0010;
    ACC = 8'd10;#10;
    
    $display("Time = %0t A = %d B = %d ACC = %d MAC OUT = %d",$time,A,B,ACC,mac_out);
    
    A = 4'b0011;
    B = 4'b0010;
    ACC = 8'd10;#10;
    
    $display("Time = %0t A = %d B = %d ACC = %d MAC OUT = %d",$time,A,B,ACC,mac_out);
  end
endmodule

OUTPUT
Time = 10 A =  3 B = 10 ACC =  10 MAC OUT =  40
Time = 20 A = 11 B = 10 ACC =  10 MAC OUT = 120
Time = 30 A =  7 B =  2 ACC =  10 MAC OUT =  24
Time = 40 A =  3 B =  2 ACC =  10 MAC OUT =  16
