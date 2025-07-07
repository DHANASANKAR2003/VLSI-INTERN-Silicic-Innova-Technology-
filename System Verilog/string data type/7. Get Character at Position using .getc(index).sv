module string_getc;
  string s = "ASIC";

  initial begin
    $display("Character at index 2: %s", s.getc(2));
  end
endmodule
