`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class environment;
  generator gen;
  driver div;
  monitor mon;
  scoreboard scb;
 
  mailbox gen2div;
  mailbox mon2scb;
  
  event myevent;
  
  virtual intf vif;
  
  function new (virtual intf vif);
    this.vif = vif;
    
    gen2div = new();
    mon2scb = new();
    gen = new(gen2div);
    div = new(vif,gen2div);
    mon = new(vif,mon2scb);
    scb = new(mon2scb);
    
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
    
  
  
