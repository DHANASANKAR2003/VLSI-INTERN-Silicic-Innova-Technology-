module assoc_array_num;
  int data[int];
  
  initial begin
    data["x"] = 8888;
    data["y"] = 7777;
    $display("number of elements = %0d",data.num());
  end
endmodule 
