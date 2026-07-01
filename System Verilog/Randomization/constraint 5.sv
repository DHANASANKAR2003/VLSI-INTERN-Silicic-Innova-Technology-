class data_frame;
  rand bit sel;
  rand bit [4:0] out;
  constraint c_sel {sel dist { 0 := 75, 1 := 25 };}
  constraint c1 {(sel == 1) -> (out == 10);}
endclass

module test;
  data_frame d1;
  initial begin
    d1 = new();
    repeat(20)begin
    d1.randomize();
      $display("sel = %0d out = %0d",d1.sel,d1.out);
    end
  end
endmodule

  
