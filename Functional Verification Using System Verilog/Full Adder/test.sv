`include "environment.sv"

program test (intf intff);
  environment env;
  
  initial begin
    env = new(intff);
    env.test_run();
  end
endprogram
  
