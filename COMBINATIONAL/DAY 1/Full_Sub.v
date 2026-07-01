//Design Code
module full_sub(
  input a,B,bin,
  output reg d,b);
  
  always@(*)
    begin
      case({a,B,bin})
        3'b000:{d,b} = 2'b00;
        3'b001:{d,b} = 2'b11;
        3'b010:{d,b} = 2'b11;
        3'b011:{d,b} = 2'b01;
        3'b100:{d,b} = 2'b10;
        3'b101:{d,b} = 2'b00;
        3'b110:{d,b} = 2'b00;
        3'b111:{d,b} = 2'b11;
    endcase
  end
endmodule
      
  //Testbench Code
module full_sub_tb;
  reg a,B,bin;
  wire d,b;
  
  full_sub uut(a,B,bin,d,b);
  
  initial begin
    
    a = 1'b0; B = 1'b0; bin = 1'b0;#10;
    a = 1'b0; B = 1'b0; bin = 1'b1;#10;
    a = 1'b0; B = 1'b1; bin = 1'b0;#10;
    a = 1'b0; B = 1'b1; bin = 1'b1;#10;
    a = 1'b1; B = 1'b0; bin = 1'b0;#10;
    a = 1'b1; B = 1'b0; bin = 1'b1;#10;
    a = 1'b1; B = 1'b1; bin = 1'b0;#10;
    a = 1'b1; B = 1'b1; bin = 1'b1;#10;
    
    $finish;
  end
  initial begin
    $dumpfile("full_sub.vcd");
    $dumpvars(1,full_sub_tb);
  end
  initial begin
    $monitor("Time = %0t \t  INPUT A = %b B = %b Bin = %b | OUTPUT  DIFF = %b BORROW = %b",$time,a,B,bin,d,b);
  end
endmodule
    
