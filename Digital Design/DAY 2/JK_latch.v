//design code
module jk_latch(
  input j,k,en,
  output reg q,qn
);
  
  assign qn = ~q;
  
  always@(*)begin
    if(en)
      q = 0;
    else
      begin
      case({j,k})
        2'b00:q = q;
        2'b01:q = 0;
        2'b10:q = 1;
        2'b11:q = ~q;
      endcase
      end
  end
endmodule

  
  
  
  module jk_latch_tb;
  reg j,k,en;
  wire q,qn;
  
  jk_latch uut(j,k,en,q,qn);
  
  initial begin
    en = 1; j = 0; k = 0; #10;  
    en = 1; j = 1; k = 0; #10;  
    en = 1; j = 0; k = 0; #10;  
    en = 1; j = 0; k = 1; #10;  
    en = 0; j = 0; k = 0; #10;  
    en = 0; j = 1; k = 1; #10;  
    en = 0; j = 0; k = 0; #10; 
    $finish;
  end
  initial begin
    $dumpfile("jk_latch.vcd");
    $dumpvars(1,jk_latch_tb);
  end
  
  initial begin
    $monitor("Time = %0t \t EN = %b J = %b K = %b Q = %b QN = %b",$time,en,j,k,q,qn);
  end
endmodule
    
