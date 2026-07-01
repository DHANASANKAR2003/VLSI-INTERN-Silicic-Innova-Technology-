module enum_explicit;
  typedef enum logic [1:0]{ON = 2'b11, 	OFF = 2'b00}power_t;
  power_t p;
  
  initial begin
    p = ON;
    $display("The power stage is %s = %0b",p.name(),p);
  end
endmodule
    
