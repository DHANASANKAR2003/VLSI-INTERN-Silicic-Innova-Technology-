7. Write Verilog code for generating an infinite clock signal with a 50% Duty cycle having a time period of 10ns using a forever loop. 

 

module clk_gen_100; 
  reg clk; 
 
  initial begin 
    clk = 1;  // Clock is always high 
    // No toggling, remains high forever 
  end 
endmodule 
