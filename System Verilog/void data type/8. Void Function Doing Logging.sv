module logging_example;
  function void log_event(input [8*50:1] event);
    $display("[log] Event = %s", event);
  endfunction

  initial begin
    log_event("The selve is Placed on HCL");
    log_event("Salary is 50,000");
  end
endmodule
