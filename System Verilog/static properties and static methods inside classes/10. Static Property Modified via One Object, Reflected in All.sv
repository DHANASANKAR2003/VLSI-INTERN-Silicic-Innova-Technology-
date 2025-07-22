class setting;
  static string mode = "IDLE";
endclass

module test;
  initial begin
    setting s1 = new();
    setting s2 = new();
    
    setting::mode = "ACTIVE";
    
    $display("s1 mode : %s",setting::mode);
    $display("s2 mode : %s",setting::mode);
  end
endmodule 
