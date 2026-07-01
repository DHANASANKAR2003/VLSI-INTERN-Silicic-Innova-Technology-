`ifndef HA_ENV_SV
`define HA_ENV_SV

import uvm_pkg::*;          // <--- ADD THIS
`include "uvm_macros.svh"

`include "ha_agent.sv"
`include "scoreboard.sv"

class env extends uvm_env;
  `uvm_component_utils(env)
  
  ha_agent agent;
  ha_scoreboard scbd;
  
  function new(string name = "env", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info("ENV", "Environment Created", UVM_LOW)
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = ha_agent::type_id::create("agent", this);
    scbd = ha_scoreboard::type_id::create("scbd", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    agent.monitor.ap.connect(scbd.analysis_export);
  endfunction
endclass

`endif
