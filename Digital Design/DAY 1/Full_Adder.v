//Design Code
module full_adder(
  input a,b,cin,
  output reg s,c);
  
  always@(*)
    begin
      case({a,b,cin})
        3'b000:{s,c} = 2'b00;
        3'b001:{s,c} = 2'b10;
        3'b010:{s,c} = 2'b10;
        3'b011:{s,c} = 2'b01;
        3'b100:{s,c} = 2'b10;
        3'b101:{s,c} = 2'b01;
        3'b110:{s,c} = 2'b01;
        3'b111:{s,c} = 2'b11;
    endcase
  end
endmodule
      
  //Testbench Code
module full_adder_tb;
  reg a,b,cin;
  wire s,c;
  
  full_adder uut(a,b,cin,s,c);
  
  initial begin
    
    a = 1'b0; b = 1'b0; cin = 1'b0;#10;
    a = 1'b0; b = 1'b0; cin = 1'b1;#10;
    a = 1'b0; b = 1'b1; cin = 1'b0;#10;
    a = 1'b0; b = 1'b1; cin = 1'b1;#10;
    a = 1'b1; b = 1'b0; cin = 1'b0;#10;
    a = 1'b1; b = 1'b0; cin = 1'b1;#10;
    a = 1'b1; b = 1'b1; cin = 1'b0;#10;
    a = 1'b1; b = 1'b1; cin = 1'b1;#10;
    
    $finish;
  end
  initial begin
    $dumpfile("full_adder.vcd");
    $dumpvars(1,full_adder_tb);
  end
  initial begin
    $monitor("Time = %0t \t  INPUT A = %b B = %b Cin = %b | OUTPUT  SUM = %b CARRY = %b",$time,a,b,cin,s,c);
  end
endmodule
    
