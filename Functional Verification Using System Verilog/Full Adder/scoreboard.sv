class scoreboard;
  mailbox mon2scb;
  event my_event;
  function new (mailbox mon2scb);
    this.mon2scb = mon2scb;
  endfunction
  
  task main();
    transaction trans;
    repeat(15)
      begin 
        mon2scb.get(trans);
        trans.display("Scoreboard signal");
        if (((trans.a ^ trans.b ^ trans.c) == trans.sum) && ((trans.a & trans.b) | (trans.a & trans.c) | (trans.b & trans.c)) == trans.carry)
          $display("--------------PASS--------------");
        else
          $display("--------------FAIL--------------");
        
        $display(" Expected: SUM = %0d, CARRY = %0d ", (trans.a ^ trans.b ^ trans.c), ((trans.a & trans.b) | (trans.a & trans.c) | (trans.b & trans.c)));
        $display("==============TRANSACTION DONE==============");
        $display("");
       ->my_event;
      end
    
  endtask
endclass
      
