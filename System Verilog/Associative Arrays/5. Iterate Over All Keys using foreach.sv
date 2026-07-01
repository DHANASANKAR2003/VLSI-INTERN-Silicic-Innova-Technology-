module assoc_array_foreach;
  int data[string];
  
  initial begin
    data["A"] = 8888;
    data["B"] = 9999;
    foreach(data[i])
      $display("data[%s] = %0d",i,data[i]);
  end
endmodule 
