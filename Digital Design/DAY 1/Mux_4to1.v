//Design Code
module mux_4to1(
  input [3:0]d,
  input[1:0]s,
  output reg y
);
  
  always@(*) begin
    case(s)
      2'b00: y = d[0];
      2'b01: y = d[1];
      2'b10: y = d[2];
      2'b11: y = d[3];
      
      default y = 1'bx;
    endcase
  end
endmodule

//Testbench code
module mux_4to1_tb;
  reg [3:0]d;
  reg [1:0]s;
  wire y;
  
  mux_4to1 uut(.d(d),.s(s),.y(y));
  
  initial begin
    d = 4'b1010;#10;
    s = 2'b00;#10;
    s = 2'b01;#10;
    s = 2'b10;#10;
    s = 2'b11;#10;
    $finish;
  end
  initial begin
    $dumpfile("mux_4to1.vcd");
    $dumpvars(1,mux_4to1_tb);
  end
  initial begin
    $monitor("Time = %0t \t S = %b  D[D3,D2,D1,D0] = %b  Y = %b ",$time,s,d,y);
  end
endmodule
    
