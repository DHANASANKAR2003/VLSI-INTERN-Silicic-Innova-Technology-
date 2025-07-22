class bank;
  static int total_balance = 0;
  int personal_balance;
  
  function void deposit(int amt);
    total_balance += amt;
    personal_balance += amt;
  endfunction
  
  function void show();
    $display("Personal : %0d Total : %0d",personal_balance,total_balance);
  endfunction
endclass

module test;
  initial begin
    bank b1 = new();
    bank b2 = new();
    
    b1.deposit(100);
    b2.deposit(150);
    
    b1.show();
    b2.show();
  end
endmodule
