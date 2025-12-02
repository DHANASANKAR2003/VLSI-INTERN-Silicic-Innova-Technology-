`ifndef HA_SEQUENCE_SV
`define HA_SEQUENCE_SV

import uvm_pkg::*;          
`include "uvm_macros.svh"  


`include "ha_transaction.sv"

class ha_sequence extends uvm_sequence#(ha_transaction);
  `uvm_object_utils(ha_sequence)
  
  function new(string name = "ha_sequence");
    super.new(name);
  endfunction
  
  task body();
    ha_transaction trans;
    `uvm_info("SEQ", "Sequence Started", UVM_LOW)
    
    repeat(5) begin
      trans = ha_transaction::type_id::create("trans");
      start_item(trans);
      if(!trans.randomize()) `uvm_error("SEQ", "RANDOMIZATION IS FAILED");
      finish_item(trans);
    end
  endtask
endclass

`endif
