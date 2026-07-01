module enum_itretion;
  typedef enum{LOW = 5, MEDIUM, HIGH = 8}level_t;
  level_t l;
  
  initial begin
    for(l = l.first(); l <= l.last(); l = l.next()) begin
      $display("LEVEL : %s = %0d",l.name(),l);
    end
  end
endmodule
