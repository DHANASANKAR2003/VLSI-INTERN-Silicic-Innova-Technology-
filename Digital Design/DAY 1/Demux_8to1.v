module mux8to1 (
  input  [7:0] d,        
  input  [2:0] sel,      
  output reg y          
);

  always @(*) begin
    case (sel)
      3'b000: y = d[0];
      3'b001: y = d[1];
      3'b010: y = d[2];
      3'b011: y = d[3];
      3'b100: y = d[4];
      3'b101: y = d[5];
      3'b110: y = d[6];
      3'b111: y = d[7];
      default: y = 1'bx; 
    endcase
  end

endmodule

module tb_mux8to1;

  reg [7:0] d;
  reg [2:0] sel;
  wire y;

  mux8to1 uut (
    .d(d),
    .sel(sel),
    .y(y)
  );

  initial begin
    
    $dumpfile("mux8to1.vcd");
    $dumpvars(0, tb_mux8to1);

    $display("Sel | Data     | Y");
    $display("----------------------");

    d = 8'b10101010;

    sel = 3'b000; #10 $display("%b   | %b | %b", sel, d, y);
    sel = 3'b001; #10 $display("%b   | %b | %b", sel, d, y);
    sel = 3'b010; #10 $display("%b   | %b | %b", sel, d, y);
    sel = 3'b011; #10 $display("%b   | %b | %b", sel, d, y);
    sel = 3'b100; #10 $display("%b   | %b | %b", sel, d, y);
    sel = 3'b101; #10 $display("%b   | %b | %b", sel, d, y);
    sel = 3'b110; #10 $display("%b   | %b | %b", sel, d, y);
    sel = 3'b111; #10 $display("%b   | %b | %b", sel, d, y);

    $finish;
  end

endmodule

