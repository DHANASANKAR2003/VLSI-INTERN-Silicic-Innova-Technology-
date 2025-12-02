`ifndef HA_AGENT_SV
`define HA_AGENT_SV

`include "ha_sequencer.sv"
`include "ha_driver.sv"
`include "ha_monitor.sv"

class ha_agent extends uvm_agent;
  `uvm_component_utils(ha_agent)
  
  ha_sequencer sequencer;
  ha_driver driver;
  ha_monitor monitor;
  
  function new(string name = "ha_agent", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info("AGENT", "Agent Created", UVM_LOW)
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = ha_monitor::type_id::create("monitor", this);
    
    if(get_is_active() == UVM_ACTIVE) begin
      driver = ha_driver::type_id::create("driver", this);
      sequencer = ha_sequencer::type_id::create("sequencer", this);
    end
  endfunction
  
  function void connect_phase(uvm_phase phase);
    if(get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction
endclass

  
`endif
