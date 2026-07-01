8. Write Verilog code to demonstrate both automatic and non-automatic tasks. 

module task_demo; 
 
  // Non-automatic task (default behavior) 
  task non_auto_task; 
    integer i; 
    begin 
      for (i = 0; i < 3; i = i + 1) 
        $display("Non-Auto Task: i = %0d", i); 
    end 
  endtask 
 
  // Automatic task (variables are local and reentrant) 
  task automatic auto_task; 
    integer j; 
    begin 
      for (j = 0; j < 3; j = j + 1) 
        $display("Auto Task: j = %0d", j); 
    end 
  endtask 
 
  initial begin 
    $display("Calling tasks sequentially:"); 
    non_auto_task(); 
    auto_task(); 
 
    $display("\nCalling tasks in parallel using fork-join:"); 
    fork 
      non_auto_task(); 
      non_auto_task(); 
    join 
 
    fork 
      auto_task(); 
      auto_task(); 
    join 
 
    $finish; 
  end 
 
endmodule 


OUTPUT 

Calling tasks sequentially: 
Non-Auto Task: i = 0 
Non-Auto Task: i = 1 
Non-Auto Task: i = 2 
Auto Task: j = 0 
Auto Task: j = 1 
Auto Task: j = 2 
 
Calling tasks in parallel using fork-join: 
Non-Auto Task: i = 0 
Non-Auto Task: i = 1 
Non-Auto Task: i = 2 
Non-Auto Task: i = 0 
Non-Auto Task: i = 1 
Non-Auto Task: i = 2 
Auto Task: j = 0 
Auto Task: j = 1 
Auto Task: j = 2 
Auto Task: j = 0 
Auto Task: j = 1 
Auto Task: j = 2 
design.sv:37: $finish called at 0 (1s) 
