//Design Code
module demux1to4 (
  input  din,          
  input  [1:0] sel,    
  output reg [3:0] y   
);

  always @(*) begin
    y = 4'b0000;
    case (sel)
      2'b00: y[0] = din;
      2'b01: y[1] = din;
      2'b10: y[2] = din;
      2'b11: y[3] = din;
      default: y = 4'bxxxx;
    endcase
  end

endmodule

//Testbench code
module tb_demux1to4;

  reg din;
  reg [1:0] sel;
  wire [3:0] y;

  demux1to4 uut (
    .din(din),
    .sel(sel),
    .y(y)
  );

  initial begin
    $display("Sel | Din | Y");
    $display("---------------");

    din = 1;

    sel = 2'b00; #10 $display("%b   |  %b  | %b", sel, din, y);
    sel = 2'b01; #10 $display("%b   |  %b  | %b", sel, din, y);
    sel = 2'b10; #10 $display("%b   |  %b  | %b", sel, din, y);
    sel = 2'b11; #10 $display("%b   |  %b  | %b", sel, din, y);

    $finish;
  end
  initial begin
    $dumpfile("demux1to4.vcd");
    $dumpvars(1,tb_demux1to4);
  end

endmodule

    
