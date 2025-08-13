`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class environment;
  generator gen;
  driver div;
  monitor mon;
  scoreboard scb;
 
  mailbox g2d;
  mailbox m2s;
  
  event myevent;
  
  virtual my_inter vif;
  
  function new (virtual my_inter vif);
    this.vif = vif;
    
    g2d = new();
    m2s = new();
    gen = new(g2d);
    div = new(vif,g2d);
    mon = new(vif,m2s);
    scb = new(m2s);
    
    gen.my_event = myevent;
    scb.my_event = myevent;
  endfunction
  
  task test_run();
    fork
      gen.main();
      div.main();
      mon.main();
      scb.main();
    join
  endtask
endclass
    
  
  
