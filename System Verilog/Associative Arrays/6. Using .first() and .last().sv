module assoc_array_first_last;
  int data[int];
  int key;
  
  initial begin
    data[0] = 4444;
    data[1] = 5555;
    data[2] = 6666;
    data[3] = 7777;
    data[4] = 8888;
    data[5] = 9999;
    
    if(data.first(key))
      $display("first data = %0d",key);
    
    if(data.last(key))
      $display("last data = %0d",key);     
  end
endmodule 
