module assoc_array_next_prev;
  int data[int];
  int key;
  
  initial begin
    data[0] = 4444;
    data[1] = 5555;
    data[2] = 6666;
    data[3] = 7777;
    data[4] = 8888;
    data[5] = 9999;
    
    key = 0;
    if(data.next(key))
      $display("next key data = %0d",key);
    key = 2;
    if(data.prev(key))
      $display("prev key data = %0d",key);     
  end
endmodule 
