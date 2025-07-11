module enum_default;
  typedef enum {A, B, C} option_t;
  option_t opt = B;

  initial begin
    case (opt)
      A: $display("Option A");
      C: $display("Option C");
      default: $display("Default: %s", opt.name());
    endcase
  end
endmodule
