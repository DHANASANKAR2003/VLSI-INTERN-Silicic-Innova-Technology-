`include "transaction.sv"

class generator;
  transaction trans;
  mailbox g2d;
  event my_event;
  
  function new(mailbox g2d);
    this.g2d = g2d;
  endfunction
  
  task main();
    repeat(15) begin
      trans = new();
      void'(trans.randomize());
      trans.display("GENERATOR SIGNAL");
      g2d.put(trans);
      @(my_event);
    end
  endtask
endclass
