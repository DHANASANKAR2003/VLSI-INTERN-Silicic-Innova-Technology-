module enum_function;
  typedef enum {LOW, MEDIUM, HIGH} level_t;

  function string describe(level_t l);
    case (l)
      LOW:    return "Low priority";
      MEDIUM: return "Medium priority";
      HIGH:   return "High priority";
    endcase
  endfunction

  initial begin
    $display("%s", describe(HIGH));
  end
endmodule
