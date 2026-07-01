//Design code
module sr_latch (
  input S, R, EN,         
  output reg Q, QN        
);

  always @(*) begin
    if (EN == 0) begin
      if (S && ~R) begin
        Q = 1;
        QN = 0;
      end
      else if (~S && R) begin
        Q = 0;
        QN = 1;
      end
      else if (~S && ~R) begin
        
      end
      else begin
        Q = 1'bx; 
        QN = 1'bx;
      end
    end
  end
endmodule


module sr_ff_master_slave (
  input S, R, CLK, RST,
  output Q, QN
);

  wire qm, qnm; 

 
  sr_latch master (
    .S(S),
    .R(R),
    .EN(~CLK),  
    .Q(qm),
    .QN(qnm)
  );

  
  sr_latch slave (
    .S(qm),
    .R(qnm),
    .EN(CLK),  
    .Q(Q),
    .QN(QN)
  );

endmodule

//Testbench code

module sr_ff_master_slave_tb;

  reg S, R, CLK, RST;
  wire Q, QN;

 
  sr_ff_master_slave uut (
    .S(S),
    .R(R),
    .CLK(CLK),
    .RST(RST),
    .Q(Q),
    .QN(QN)
  );

  
  initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;  
  end

 
  initial begin
    RST = 1; S = 0; R = 1;#10;
    RST = 0;
    S = 1; R = 0;#10;
    S = 0; R = 0;#10;
    S = 0; R = 1;#10;
    S = 1; R = 1;#10;
    S = 1; R = 1;#10;
    S = 0; R = 0;#10;
    S = 1; R = 0;#10;
    S = 0; R = 1;#10;
    $finish;
    $finish;
  end

  
  initial begin
    $dumpfile("sr_ff_master_slave.vcd");
    $dumpvars(0, sr_ff_master_slave_tb);
  end

  
  initial begin
    $monitor("Time=%0t | CLK=%b | RST = %b | S=%b | R=%b | Q=%b | QN=%b", 
              $time, CLK, RST, S, R, Q, QN);
  end

endmodule

