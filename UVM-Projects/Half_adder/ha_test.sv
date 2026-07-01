`ifndef HA_TEST_SV
`define HA_TEST_SV

import uvm_pkg::*;          // <--- ADD THIS
`include "uvm_macros.svh"  // <--- ADD THIS


`include "env.sv"
`include "ha_sequence.sv"

class ha_test extends uvm_test;
  `uvm_component_utils(ha_test)
  
  env e;
  ha_sequence seq;
  
  function new(string name = "ha_test", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    ha_sequence seq;
    phase.raise_objection(this);
    
    seq = ha_sequence::type_id::create("seq");
    seq.start(e.agent.sequencer);
    #1000;
    phase.drop_objection(this);
  endtask
endclass

`endif

  
    
