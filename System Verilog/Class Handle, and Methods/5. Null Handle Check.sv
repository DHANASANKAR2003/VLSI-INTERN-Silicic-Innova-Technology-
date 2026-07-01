class device;
  int id;
endclass

module test1;
  device d;
  
  initial begin
    if(d == null)
      $display("handle is null");
    
    d = new();
    d.id = 123;
    $display("Device id = %0d",d.id);
    
  end
endmodule
    
