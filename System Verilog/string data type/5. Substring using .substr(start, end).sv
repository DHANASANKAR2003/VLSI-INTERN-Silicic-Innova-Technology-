module basic_string;
  string name = "DHANASAKAR";
  
  initial begin
    $display("string name is %s",name.substr(0,5));
  end
endmodule 
