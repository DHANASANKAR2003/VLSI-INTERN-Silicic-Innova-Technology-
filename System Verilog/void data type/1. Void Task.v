
module void_task_display;
  task void_display();
    $display("This is void task display");
  endtask
  
  initial begin
    void_display();
  end
endmodule 
