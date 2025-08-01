class data_frame;
  rand bit [1:0] sel;
  randc bit [4:0] addr;
  constraint c1{sel == 2;}
  constraint c2{addr == sel*5;}
endclass

module test;
  data_frame d1;
  initial begin
    d1 = new();
    repeat(10)begin
    d1.randomize();
      $display("sel = %0d addr = %0d",d1.sel,d1.addr);
    end
  end
endmodule

  
