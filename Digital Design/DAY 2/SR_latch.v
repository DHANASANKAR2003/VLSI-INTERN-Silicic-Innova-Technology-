//design code
module sr_latch(
  input s,r,
  output reg q,qn
);
  
  assign qn = ~q;
  
  always@(*)begin
    if(s==0 && r==1)
      q = 0;
  else if(s==1 && r==0)
    q = 1;
  else if(s==0 && r==0)
    q = q;
  else
    q = 1'bx;
  end
endmodule

  
  
  
  module sr_latch_tb;
  reg s,r;
  wire q,qn;
  
  sr_latch uut(s,r,q,qn);
  
  initial begin
    s = 0; r = 0; #10;  
    s = 1; r = 0; #10;  
    s = 0; r = 0; #10;  
    s = 0; r = 1; #10;  
    s = 0; r = 0; #10;  
    s = 1; r = 1; #10;  
    s = 0; r = 0; #10; 
    $finish;
  end
  initial begin
    $dumpfile("sr_latch.vcd");
    $dumpvars(1,sr_latch_tb);
  end
  
  initial begin
    $monitor("Time = %0t \t S = %b R = %b Q = %b QN = %b",$time,s,r,q,qn);
  end
endmodule
    
