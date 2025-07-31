class packet #(parameter type T = int);
  T item[50];
  int i = 0;
  function void push(input T val);
    if(i<50) begin
      item[i] = val;
      $display("push into item[%0d] = %1.2f",i,val);
      i++;
    end
    else begin
      $display("container overflow. cannot push %1.2f",i,val);
    end
  endfunction

  function T pop();
    T popped_val;
    if(i>0) begin
      i--;
      popped_val = item[i];
      $display("pop from item[%0d] = %1.2f",i,popped_val);
      return popped_val;
    end
    else begin
      $display("container underflow. cannot pop.");
    end
  endfunction
endclass

module class_example;
  packet int_p1;
  packet #(bit [2:0]) bit_p2;
  packet #(real) real_p3;
  
  initial begin
    int_p1 = new();
    bit_p2 = new();
    real_p3 = new();
    int_p1.push(15);
    bit_p2.push(3);
    real_p3.push(5.12);
    
    $display("popped value(int_p1) = %1.2f",int_p1.pop());
    $display("popped value(bit_p2) = %1.2f",bit_p2.pop());
    $display("popped value(real_p3) = %1.2f",real_p3.pop());
  end
endmodule
  
      
