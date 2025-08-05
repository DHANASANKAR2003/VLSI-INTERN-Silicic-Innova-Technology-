class transaction;
  rand bit d;
  bit q;
  bit clk;
  bit rst;

  function void display(string name);
    $display("%s---->", name);
    $display("time = %0t | D = %0d | Q = %0d | CLK = %0d | RST = %0d", $time, d, q,clk,rst);
    $display("");
  endfunction
endclass
