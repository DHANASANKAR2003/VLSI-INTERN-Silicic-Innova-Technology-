module dynamic_arr_basic;
  int da[];
  
  initial begin
    da = new[5];
    $display("dynamic array size = %0d",da.size());
  end
endmodule 
