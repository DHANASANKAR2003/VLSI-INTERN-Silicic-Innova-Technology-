class monitor;
  virtual intf vif;
  mailbox mon2scb;
  
  function new (virtual intf vif, mailbox mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
  endfunction
  
  task main();
    repeat(15)    
      begin      
        transaction trans;
        trans = new();
        #1;
        trans.a = vif.a;
        trans.b = vif.b;
        trans.c = vif.c;
        trans.sum = vif.sum;
        trans.carry = vif.carry; 
        trans.display("Monitor class signal");
        mon2scb.put(trans);
      end
  endtask
endclass
    
