interface simple_if;
  task info();
    $display("Interface task executed...");
  endtask
endinterface 

module info_if();
  simple_if si();
  
  initial begin
    //si = new();
    si.info();
  end
endmodule 

    
