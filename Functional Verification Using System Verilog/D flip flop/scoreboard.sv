class scoreboard;
  mailbox mon2scb;
  event my_event;
  function new (mailbox mon2scb);
    this.mon2scb = mon2scb;
  endfunction
  
  task main();
    transaction trans;
    repeat(4)
      begin 
        mon2scb.get(trans);
        trans.display("Scoreboard signal");
        if (trans.q == trans.d)
          $display("--------------PASS--------------");
        else
          $display("--------------FAIL--------------");
        
        $display(" Expected: Q = %0d", trans.q);
        $display("==============TRANSACTION DONE==============");
        $display("");
       ->my_event;
      end
    
  endtask
endclass
      
