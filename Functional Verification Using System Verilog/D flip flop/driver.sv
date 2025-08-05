class driver;
  virtual intf vif;
  mailbox gen2div;
  
  function new(virtual intf vif, mailbox gen2div);
    this.vif = vif;
    this.gen2div = gen2div;
  endfunction
  
  task main();
    repeat(4)
      begin     
        transaction trans;
        trans = new();
        gen2div.get(trans);
        @(posedge vif.clk);
        vif.d = trans.d;
        trans.display("Driver class signal");
        #1;
      end
  endtask
endclass
