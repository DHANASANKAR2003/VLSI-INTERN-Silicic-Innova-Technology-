//design code
module d_latch(
  input d,en,
  output reg q
);
  always@(*)
    begin
      if(en)
        q = d;
      else
        q = 0;
    end
endmodule
  
  
  module d_latch_tb;
  reg d,en;
  wire q;
  
  d_latch uut(d,en,q);
  
  initial begin
    d = 0;
    en = 0;#10;
    d = 1;#10;
    en = 1;#10;
    d = 0;#10;
    en = 0;#10;
    d = 1;#10;
    en = 1;#10;
    $finish;
  end
  initial begin
    $dumpfile("d_latch.vcd");
    $dumpvars(1,d_latch_tb);
  end
  
  initial begin
    $monitor("Time = %0t \t EN = %b D = %b Q = %b",$time,en,d,q);
  end
endmodule
    
