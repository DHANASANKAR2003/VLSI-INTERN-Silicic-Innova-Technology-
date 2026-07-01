`include "environment.sv"

program test (intf intff);
  environment env;
  
  initial begin
    intff.rst = 1;
    repeat (2) @(posedge intff.clk); 
    intff.rst = 0;
  end
  
  initial begin
    env = new(intff);
    env.test_run();
  end
endprogram
  
