module simple_task;
  int a = 5,b = 5,result;
  
  initial begin
    simple_task(a,b,result);
    $display("Multiplicatin of a and b is %0d",result);
  end
  
  task simple_task(input int a,b,output int result);
    #2;
    result = a * b;
  endtask
endmodule


output

Multiplicatin of a and b is 25
