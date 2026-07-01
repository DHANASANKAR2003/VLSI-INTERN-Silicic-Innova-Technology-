module basic_string;
  string name1 = "DHANASAKAR";
  string name2 = "DHANASAAKAR";
  
  initial begin
    if(name1.compare(name2)==0)
      $display("string name is equal...");
    else
      $display("string name is not equal...");
  end
endmodule 
