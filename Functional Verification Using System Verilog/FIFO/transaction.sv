class transaction;
  rand bit [7:0] din;
  rand bit wr_en, rd_en;
  bit [7:0] dout;
  bit full, empty;

  function void display(string name);
    $display("%s---->", name);
    $display("time = %0t | WR_EN = %0d | RD_EN = %0d | DIN = %0d | DOUT = %0d | FULL = %0d | EMPTY = %0d",
             $time, wr_en, rd_en, din, dout, full, empty);
    $display("");
  endfunction
endclass
