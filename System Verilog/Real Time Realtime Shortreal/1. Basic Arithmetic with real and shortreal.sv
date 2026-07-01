module rea_shortreal;
  real r = 5.299999999999999986943689236783467863427856789567346583438;
  shortreal sr = 2.59999999999999;
  
  initial begin 
    $display("Real = %f",r);
    $display("Shortreal = %f",sr);
    $display("sum = %f",r + sr);
  end
endmodule 
