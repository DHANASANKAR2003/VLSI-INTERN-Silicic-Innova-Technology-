class data;
  static int value = 42;
endclass

module test;
  initial begin
    $display("Data value : %0d",data::value);
  end
endmodule 
