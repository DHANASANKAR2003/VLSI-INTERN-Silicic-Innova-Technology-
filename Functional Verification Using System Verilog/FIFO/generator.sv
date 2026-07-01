`include "transaction.sv"
class generator;
  transaction trans;
  event my_event;
  mailbox gen2div;
  
  function new(mailbox gen2div);
    this.gen2div = gen2div;
  endfunction
  
  task main();
    repeat(10) begin
      trans = new();
      void'(trans.randomize());
      trans.display("Generator class signal");
      gen2div.put(trans);
      @(my_event);
    end
  endtask
endclass

  
