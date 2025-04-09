//design code
module t_latch(
  input wire t,en,
  output reg q,qn
);
  
  assign qn = ~q;
  
  always@(*)begin
    if(en)begin
      if(t)
        q = ~t;
    else
      q = ~t;
  end
  end
endmodule

  
  
  
  module t_latch_tb;
  reg t,en;
  wire q,qn;
  
  t_latch uut(t,en,q,qn);
  
  initial begin
    en = 1; t = 0; #10;  
    en = 1; t = 1; #10;  
    en = 1; t = 0; #10;  
    en = 1; t = 1; #10;  
    en = 0; t = 0; #10;  
    en = 0; t = 1; #10;  
    en = 0; t = 0; #10;
    en = 0; t = 1; #10;
    $finish;
  end
  initial begin
    $dumpfile("t_latch.vcd");
    $dumpvars(1,t_latch_tb);
  end
  
  initial begin
    $monitor("Time = %0t \t EN = %b T = %b Q = %b QN = %b",$time,en,t,q,qn);
  end
endmodule
    
