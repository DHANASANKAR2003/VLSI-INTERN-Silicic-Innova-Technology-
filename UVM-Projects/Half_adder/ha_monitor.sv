`ifndef HA_MONITOR_SV
`define HA_MONITOR_SV

`include "ha_transaction.sv"
`include "interface.sv"

class ha_monitor extends uvm_monitor;
  `uvm_component_utils(ha_monitor)
  
  virtual ha_interface vif;
  uvm_analysis_port #(ha_transaction) ap;
  ha_transaction trans;
  
  function new(string name = "ha_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ha_interface)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "Virtual interface not found in Monitor")
      ap = new("ap", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    ha_transaction trans;
    repeat(5) begin
      @(vif.drv_done);
      trans = ha_transaction::type_id::create("trans");
      trans.a = vif.a;
      trans.b = vif.b;
      trans.s = vif.s;
      trans.c = vif.c;
      ap.write(trans);
      `uvm_info("MON", $sformatf("Monitored: %s", trans.convert2string()), UVM_LOW)
    end
  endtask
endclass

`endif
