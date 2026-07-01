module assoc_array_int_key;
  int data[int];
  
  initial begin
    data[0190] = 8888;
    $display("ID 0190 = %0d",data[0190]);
    data[9384] = 7777;
    $display("ID 9384 = %0d",data[9384]);
  end
endmodule 
