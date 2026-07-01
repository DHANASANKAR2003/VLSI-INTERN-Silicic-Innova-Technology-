module void_nested();
  function void display_call(string s);
    $display("the string = %s",s);
  endfunction
  
  task call_function;
    display_call("called from task");
  endtask
  
  initial begin
    call_function();
  end
endmodule 
  
