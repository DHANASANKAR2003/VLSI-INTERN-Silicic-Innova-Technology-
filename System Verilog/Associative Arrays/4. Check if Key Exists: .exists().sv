module assoc_array_exists;
  int data[int];
  
  initial begin
    data[3] = 8888;
    if(data.exists(3))
      $display("Key 3 exists with value = %0d",data[3]);
    else
      $display("Key dose not exists");
  end
endmodule 
