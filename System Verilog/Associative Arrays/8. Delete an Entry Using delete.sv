module assoc_array_delete;
  int data[int];
  
  initial begin
    data[0] = 4444;
    data[1] = 5555;
    data[2] = 6666;
    data[3] = 7777;
    data[4] = 8888;
    data[5] = 9999;
    
    data.delete(1);
    if(!data.exists(1))
      $display("data 1 deleted");
    
    data.delete(2);
    if(!data.exists(2))
      $display("data 2 deleted"); 
    
    foreach (data[key])
      $display("data[%0d] = %0d", key, data[key]);
  end
endmodule 
