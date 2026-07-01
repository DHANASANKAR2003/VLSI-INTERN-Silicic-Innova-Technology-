class tracker;
  static int object_count = 0;
  
  function new();
    object_count++;
  endfunction
endclass

module test;
  initial begin
    tracker t1 = new();
    tracker t2 = new();
    tracker t3 = new();
    $display("total count : %0d",tracker::object_count);
  end
endmodule
