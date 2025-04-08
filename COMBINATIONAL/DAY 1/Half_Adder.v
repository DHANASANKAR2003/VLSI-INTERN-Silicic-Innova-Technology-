//Design Code
module half_adder(
  input a,b,
  output reg s,c);
  
  always@(*)
    begin
    case({a,b})
      2'b00:{s,c} = 2'b00;
      2'b01:{s,c} = 2'b10;
      2'b10:{s,c} = 2'b10;
      2'b11:{s,c} = 2'b01;
    endcase
  end
endmodule

//Testbench Code
module half_adder_tb;
  reg a,b;
  wire s,c;
  
  half_adder uut(a,b,s,c);
  
  initial begin
    
    a = 1'b0; b = 1'b0;#10;
    a = 1'b0; b = 1'b1;#10;
    a = 1'b1; b = 1'b0;#10;
    a = 1'b1; b = 1'b1;#10;
    $finish;
  end
  initial begin
    $dumpfile("half_adder.vcd");
    $dumpvars(1,half_adder_tb);
  end
  initial begin
    $monitor("Time = %0t \t  INPUT A = %b B = %b | OUTPUT  SUM = %b CARRY = %b",$time,a,b,s,c);
  end
endmodule
    
