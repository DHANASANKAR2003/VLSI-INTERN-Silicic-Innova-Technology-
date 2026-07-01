class config;
  static const int width = 8;
endclass
  
module test;
  initial begin
    $display("WIDTH = %0d",config::width);
  end
endmodule
  
