class data_frame;
  rand bit [4:0] data;
  constraint c1{data >= 10; data <=30;}
endclass

module test;
  data_frame d1;
  initial begin
    d1 = new();
    repeat(10)begin
    d1.randomize();
      $display("The randomize value = %0d",d1.data);
    end
  end
endmodule

  
