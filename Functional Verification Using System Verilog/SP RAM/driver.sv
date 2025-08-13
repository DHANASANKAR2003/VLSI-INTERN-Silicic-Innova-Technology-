class driver;
  virtual my_inter vif;
  mailbox g2d;
  
  function new(virtual my_inter vif,mailbox g2d);
    this.vif = vif;
    this.g2d = g2d;
  endfunction
  
  task main();
    repeat(15) begin
      transaction trans;
      trans = new();
      g2d.get(trans);
      @(posedge vif.clk);
      vif.en = trans.en;
      vif.addr = trans.addr;
      vif.din = trans.din;
      trans.display("DRIVER SIGNAL");
      #1;
    end
  endtask
endclass
