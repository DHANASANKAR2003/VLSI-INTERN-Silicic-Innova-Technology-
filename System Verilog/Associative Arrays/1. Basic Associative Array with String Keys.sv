module assoc_array_string_key;
  int data[string];
  
  initial begin
    data["apple"] = 10;
    $display("apple = %0d",data["apple"]);
    data["banana"] = 20;
    $display("banana = %0d",data["banana"]);
  end
endmodule 
