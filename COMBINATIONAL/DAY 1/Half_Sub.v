//Design Code
module half_sub(
  input a,b,
  output reg d,B);
  
  always@(*)
    begin
    case({a,b})
      2'b00:{d,B} = 2'b00;
      2'b01:{d,B} = 2'b10;
      2'b10:{d,B} = 2'b10;
      2'b11:{d,B} = 2'b01;
    endcase
  end
endmodule


//Testbench Code
module half_sub_tb;
  reg a,b;
  wire d,B;
  
  half_sub uut(a,b,d,B);
  
  initial begin
    
    a = 1'b0; b = 1'b0;#10;
    a = 1'b0; b = 1'b1;#10;
    a = 1'b1; b = 1'b0;#10;
    a = 1'b1; b = 1'b1;#10;
    $finish;
  end
  initial begin
    $dumpfile("half_sub.vcd");
    $dumpvars(1,half_sub_tb);
  end
  initial begin
    $monitor("Time = %0t \t  INPUT A = %b B = %b | OUTPUT  DIFF = %b BORROW = %b",$time,a,b,d,B);
  end
endmodule
    
  
