class globel;
  static int g = 10;
  
  static function void show();
    $display("globe value : %0d",g);
  endfunction
endclass

module test;
  initial begin
    globel::show();
  end
endmodule 
