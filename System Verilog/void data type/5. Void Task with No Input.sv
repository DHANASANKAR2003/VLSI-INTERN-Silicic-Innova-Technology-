module simple_void_task;
  task automatic say_hello;
    $display("void created by selva say hello");
  endtask
  
  task automatic say_hii;
    $display("void created by selva say hii");
  endtask
  
  initial begin
    say_hello();
    say_hii();
  end
endmodule 
  
