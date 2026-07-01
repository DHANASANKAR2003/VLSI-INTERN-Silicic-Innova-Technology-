module dyn_array_realloc;
  int da[];

  initial begin
    da = new[3];
    da = '{1, 2, 3};
    $display("Old size: %0d", da.size());

    da = new[6];  
    da = '{1, 2, 3, 4, 5, 6};
    $display("New size: %0d", da.size());
  end
endmodule
