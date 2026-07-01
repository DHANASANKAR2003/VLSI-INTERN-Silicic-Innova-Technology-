 module dyn_array_delete;
   int da[] = '{9,7,8,5,6,2,3,1,4};

  initial begin
    da.delete();
    $display("size after delete = %0d",da.size());
  end
endmodule
