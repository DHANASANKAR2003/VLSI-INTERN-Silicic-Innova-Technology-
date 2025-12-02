`ifndef HA_SEQUENCER_SV
`define HA_SEQUENCER_SV

`include "ha_transaction.sv"

class ha_sequencer extends uvm_sequencer #(ha_transaction);
  `uvm_component_utils(ha_sequencer)
  
  function new(string name = "ha_sequencer", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info("SEQ_R", "Sequencer Created", UVM_LOW)
  endfunction
endclass

`endif
