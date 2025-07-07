module real_delay_time;
  real delay_time = 2.5;
  
  initial begin
    $display("Waiting for %0f time units...", delay_time);
    #delay_time;
    $display("Delay complete at time %0t", $time);
  end
endmodule
