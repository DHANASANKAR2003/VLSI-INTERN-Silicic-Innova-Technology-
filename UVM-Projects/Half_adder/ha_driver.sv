`ifndef HA_DRIVER_SV
`define HA_DRIVER_SV

`include "ha_transaction.sv"
`include "interface.sv"

class ha_driver extends uvm_driver #(ha_transaction);
  `uvm_component_utils(ha_driver)
  
  virtual ha_interface vif;
  
  function new(string name = "ha_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual ha_interface)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "Virtual interface not found in Driver")
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      driver(req);
      seq_item_port.item_done();
    end
  endtask
  
  task driver(ha_transaction trans);
    vif.a <= trans.a;
    vif.b <= trans.b;
    #10;
    
    -> vif.drv_done;
    `uvm_info("DRV", $sformatf("Driving: INPUT A = %d \t B = %d", trans.a, trans.b), UVM_LOW)
 
  endtask
endclass

`endif
