class monitor;
  virtual intf vif;
  mailbox mon2scb;
  
  function new (virtual intf vif, mailbox mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
  endfunction
  
  task main();
    repeat(4)    
      begin      
        transaction trans;
        trans = new();
        #1;
        @(posedge vif.clk);
        trans.d = vif.d;
        trans.clk = vif.clk;
        trans.rst = vif.rst;
        trans.q = vif.q; 
        trans.display("Monitor class signal");
        mon2scb.put(trans);
      end
  endtask
endclass
    
