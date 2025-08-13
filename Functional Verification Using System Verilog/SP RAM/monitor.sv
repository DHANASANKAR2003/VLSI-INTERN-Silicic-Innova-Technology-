class monitor;
  virtual my_inter vif;
  mailbox m2s;
  
  function new (virtual my_inter vif,mailbox m2s);
    this.vif = vif;
    this.m2s = m2s;
  endfunction
  transaction trans;
  task main();
    repeat(15) begin
      trans = new();
      @(posedge vif.clk);
      #1;
      trans.en = vif.en;
      trans.addr = vif.addr;
      trans.din = vif.din;
      trans.dout = vif.dout;
      trans.display("MONITOR SIGNAL");
      m2s.put(trans);
    end
  endtask
endclass
