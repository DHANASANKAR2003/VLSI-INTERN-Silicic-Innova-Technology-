`include "environment.sv"

program test (my_inter interf);
  environment env;
  
  initial begin
    interf.rst <= 1;
    repeat (2) @(posedge interf.clk); 
    interf.rst <= 0;
  end
  
  initial begin
    env = new(interf);
    env.test_run();
  end
endprogram
  
