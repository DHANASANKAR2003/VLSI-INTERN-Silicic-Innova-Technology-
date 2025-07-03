module void_assertion;
  function void check_positive(int value);
    assert(value > 0)
    else 
      $fatal(1, "Its not positive..!");
  endfunction
  
  initial begin
    check_positive(5);
    check_positive(-2);
  end
endmodule 
