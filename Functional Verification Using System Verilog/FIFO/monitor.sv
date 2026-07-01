class monitor;
  virtual intf vif;
  mailbox mon2scb;
  
  function new (virtual intf vif, mailbox mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
  endfunction
  
  task main();
    repeat(10)    
      begin      
        transaction trans;
        trans = new();
        @(posedge vif.clk);
        #1;
        trans.din   = vif.din;
        trans.dout  = vif.dout;
        trans.wr_en = vif.wr_en;
        trans.rd_en = vif.rd_en;
        trans.full  = vif.full;
        trans.empty = vif.empty;
        trans.display("Monitor class signal");
        mon2scb.put(trans);
      end
  endtask
endclass
    
