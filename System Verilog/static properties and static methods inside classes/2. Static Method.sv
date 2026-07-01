class utils;
  static function int square(int x);
    return x * x;
  endfunction
endclass

module test;
  initial begin
    int result = utils::square(6);
    $display("square of the value : %0d",result);
  end
endmodule
