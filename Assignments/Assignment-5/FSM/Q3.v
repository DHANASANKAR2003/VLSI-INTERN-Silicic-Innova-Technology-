3. The purpose of this lab is to build a Binary-to-BCD converter using the double
dabble algorithm (aka the shift-add-3 algorithm). You will only utilize
combinational circuit components, verify the functionality of the converter using
a testbench
//Design Code
module Binary_toBCD (
  input [7:0]B_in,
  output reg[3:0]once,
  output reg[3:0]tens,
  output reg[3:0]hundreds
);
  
  reg [19:0]shift_reg;
  integer i;
  
  always@(*)
    begin
      shift_reg = 20'b0;
      shift_reg[7:0] = B_in;
      
      for(i = 0;i<8;i = i + 1)begin
        if(shift_reg[11:8]>=5)
          shift_reg[11:8] = shift_reg[11:8] + 3;
        if(shift_reg[15:11]>=5)
          shift_reg[15:11] = shift_reg[15:11] + 3;
        if(shift_reg[19:15]>=5)
          shift_reg[19:15] = shift_reg[19:15] + 3;
        
        shift_reg = shift_reg << 1;
      end
    end
  assign once = shift_reg[11:8];
  assign tens = shift_reg[15:11];
  assign hundreds = shift_reg[19:15];
  
endmodule

//Testbench
module Binary_to_BCD_tb;
  reg [7:0]B_in;
  wire [3:0]once,tens,hundreds;
  
  Binary_toBCD uut(
    .B_in(B_in),
    .once(once),
    .tens(tens),
    .hundreds(hundreds));
  initial begin
    B_in = 5;#10;
    B_in = 10;#10;
    B_in = 50;#10;
    B_in = 150;#10;
    B_in = 200;#10;
    B_in = 250;#10;
    B_in = 255;#10;
    B_in = 175;#10;
  end
  initial begin 
    $monitor("Time=%0t | Binary Input=%d | Hundreds=%d Tens=%d Ones=%d", $time, B_in, hundreds, tens, once);
  end
endmodule

OUTPUT
Time=0  | Binary Input=  5 | Hundreds= 0 Tens= 0 Ones= 5
Time=10 | Binary Input= 10 | Hundreds= 0 Tens= 2 Ones= 0
Time=20 | Binary Input= 50 | Hundreds= 1 Tens= 0 Ones= 0
Time=30 | Binary Input=150 | Hundreds= 3 Tens= 0 Ones= 0
Time=40 | Binary Input=200 | Hundreds= 5 Tens= 2 Ones= 0
Time=50 | Binary Input=250 | Hundreds= 5 Tens=12 Ones= 0
Time=60 | Binary Input=255 | Hundreds= 5 Tens=12 Ones= 5
Time=70 | Binary Input=175 | Hundreds= 3 Tens= 4 Ones= 5
