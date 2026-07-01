class data_frame;
  rand bit [4:0] data;
endclass

module test;
  data_frame d1;
  initial begin
    d1 = new();
    repeat(40)begin
    d1.randomize();
      $display("The randomize value = %0d",d1.data);
    end
  end
endmodule

  
