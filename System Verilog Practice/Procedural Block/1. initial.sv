module initial_block;
  logic [3:0]a,b;
  int sum;
  bit done;
  
  initial begin
    a = 4'd5;
    b = 4'd10;
    
    $display("value of a %0d",a);
    $display("value of a %0d",b);
    
    sum = a + b;
    done = 1;
    $display("sum of (a + b) is %0d and done %0d",sum,done);
  end
endmodule

OUTPUT

value of a 5
value of a 10
sum of (a + b) is 15 and done 1
