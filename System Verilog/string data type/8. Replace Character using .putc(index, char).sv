module string_putc;
  string s = "VLSI";

  initial begin
    s.putc(1, "x");
    $display("Modified String: %s", s);
  end
endmodule
