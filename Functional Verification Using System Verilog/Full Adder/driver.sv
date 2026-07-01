class driver;
  virtual intf vif;
  mailbox gen2div;
  
  function new(virtual intf vif, mailbox gen2div);
    this.vif = vif;
    this.gen2div = gen2div;
  endfunction
  
  task main();
    repeat(15)
      begin     
        transaction trans;
        trans = new();
        gen2div.get(trans);
        vif.a = trans.a;
        vif.b = trans.b;
        vif.c = trans.c;
        trans.display("Driver class signal");
        #1;
      end
  endtask
endclass
