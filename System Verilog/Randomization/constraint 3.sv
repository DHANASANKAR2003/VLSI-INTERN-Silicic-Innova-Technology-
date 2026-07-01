class data_frame;
  rand bit [1:0]sel;
  randc bit [4:0] out;
  constraint c1 {if(sel == 1) out == 10; else if (sel == 0) out == 5; else out == 12;}
endclass

module test;
  data_frame d1;
  initial begin
    d1 = new();
    repeat(10)begin
    d1.randomize();
      $display("sel = %0d out = %0d",d1.sel,d1.out);
    end
  end
endmodule

  
