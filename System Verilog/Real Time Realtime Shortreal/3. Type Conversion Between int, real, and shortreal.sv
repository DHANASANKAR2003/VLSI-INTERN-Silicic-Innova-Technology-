module real_type_conversion;
  int a = 9.4;
  real b;
  shortreal c;
  
  initial begin
    b = a;
    c = b;
    $display("int = %0d real = %f shortreal = %f",a,b,c);
  end
endmodule 
