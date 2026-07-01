//Design Code
module mux_8to1(
  input [7:0]d,
  input[2:0]s,
  output reg y
);
  
  always@(*) begin
    case(s)
      3'b000: y = d[0];
      3'b001: y = d[1];
      3'b010: y = d[2];
      3'b011: y = d[3];
      3'b100: y = d[4];
      3'b101: y = d[5];
      3'b110: y = d[6];
      3'b111: y = d[7];
      
      default y = 1'bx;
    endcase
  end
endmodule 

//Testbench code
module mux_8to1_tb;
  reg [7:0]d;
  reg [2:0]s;
  wire y;
  
  mux_8to1 uut(.d(d),.s(s),.y(y));
  
  initial begin
    d = 8'b10101010;#10;
    s = 3'b000;#10;
    s = 3'b001;#10;
    s = 3'b010;#10;
    s = 3'b011;#10;
    s = 3'b100;#10;
    s = 3'b101;#10;
    s = 3'b110;#10;
    s = 3'b111;#10;
    $finish;
  end
  initial begin
    $dumpfile("mux_8to1.vcd");
    $dumpvars(1,mux_8to1_tb);
  end
  initial begin
    $monitor("Time = %0t \t S = %b  D[D7,D6,D5,D4D3,D2,D1,D0] = %b  Y = %b ",$time,s,d,y);
  end
endmodule
    
