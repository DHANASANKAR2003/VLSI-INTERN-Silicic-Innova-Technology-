class transaction;
  rand bit a;
  rand bit b;
  rand bit c;
  
  bit sum;
  bit carry;
  
  function void display(string name);
    $display("%s---->",name);
    $display("time = %0t, A = %0d | B = %0d | C = %0d | SUM = %0d | CARRY = %0d",$time,a,b,c,sum,carry);
    $display("");
  endfunction
endclass

