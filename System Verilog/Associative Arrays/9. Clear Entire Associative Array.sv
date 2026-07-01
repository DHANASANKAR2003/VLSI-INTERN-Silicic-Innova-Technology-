module assoc_array_clear;
  int data[string];

  initial begin
    data["one"] = 1;
    data["two"] = 2;
    data.delete();  
    $display("Number of elements after delete = %0d", data.num());
  end
endmodule
