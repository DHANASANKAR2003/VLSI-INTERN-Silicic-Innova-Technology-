class math;
  static function int cube(int x);
    return x*x*x;
  endfunction
endclass

module test;
  initial begin
    math m;
    $display("cube = %0d",m.cube(3));
  end
endmodule
