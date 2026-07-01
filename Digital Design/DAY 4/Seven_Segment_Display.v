//Design code
module seven_segment_display(
  input [3:0]bin,
  output reg [6:0]seg);
  
  always@(*) begin
    case (bin)
      4'd0: seg = 7'b1111110;
      4'd1: seg = 7'b0110000;
      4'd2: seg = 7'b1101101;
      4'd3: seg = 7'b1111001;
      4'd4: seg = 7'b0110011;
      4'd5: seg = 7'b1011011;
      4'd6: seg = 7'b1011111;
      4'd7: seg = 7'b1110000;
      4'd8: seg = 7'b1111111;
      4'd9: seg = 7'b1111011;
      default: seg = 7'b0000000; 
    endcase
  end
endmodule

//testbench code
module seven_segment_display_tb();
  reg [3:0]bin;
  wire [6:0]seg;
  
  seven_segment_display uut(bin,seg);
  
  initial begin
    for(bin = 0;bin < 10;bin = bin +1)begin#5;
     $display("%d\t%b",bin,seg);
    end
 
    $finish;
  end
  initial begin
    $dumpfile("seven_segment_display.vcd");
    $dumpvars(1,seven_segment_display_tb);
  end
  initial begin
    $display("BIN\tSEG");
   
  end
endmodule
  
