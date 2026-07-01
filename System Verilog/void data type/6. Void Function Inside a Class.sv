class message;
  string msg;
  
  function show();
    $display("Message = %s",msg);
  endfunction
endclass

module test;
  initial begin
    message m = new();
    m.msg = "SELVARAGAVAN PLACED ON HCL";
    m.show();
  end
endmodule 
