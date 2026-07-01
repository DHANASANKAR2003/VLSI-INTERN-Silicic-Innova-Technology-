module task_fact;
  int result1,result2,var1,var2;
  event a,b;
  
  task fact_task(int var1);
    #1;
    if(var1 >= 2) begin
      fact_task(var1 - 1);
      result1 = result1 * var1;
    end
    else begin
      result1 = 1;
      ->a;
    end  
  endtask
  
  task automatic fact_autotask(int var2);
    #1;
    if(var2 >= 2) begin
      fact_autotask(var2 - 1);
      result2 = result2 * var2;
    end
    else begin
      result2 = 1;
      ->b;
    end  
  endtask
  
  initial begin
    fork
      fact_task(5);
      fact_autotask(5);
    join
    
    fork
      wait(a.triggered);
      $display("fact static : %0d",result1);
      wait(b.triggered);
      $display("fact automatic : %0d",result2);
    join
    
  end
endmodule


output

fact static : 1
fact automatic : 120
