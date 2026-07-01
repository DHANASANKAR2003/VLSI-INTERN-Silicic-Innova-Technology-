`ifndef HA_SCOREBOARD_SV
`define HA_SCOREBOARD_SV

`include "ha_transaction.sv"

class ha_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(ha_scoreboard)
  
  uvm_analysis_imp #(ha_transaction, ha_scoreboard) analysis_export;
  
  function new(string name = "ha_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_export = new("analysis_export", this);
  endfunction
  
  function void write(ha_transaction trans);
    bit exp_s;
    bit exp_c;
    
    exp_s = trans.a ^ trans.b;
    exp_c = trans.a & trans.b;
    
    if(trans.s !== exp_s || trans.c !== exp_c) begin
            `uvm_error("SCBD", $sformatf("MISMATCH! Input: a=%b, b=%b | Expected: sum=%b, carry=%b | Actual: sum=%b, carry=%b",
                trans.a, trans.b, exp_s, exp_c, trans.s, trans.c))
        end else begin
            `uvm_info("SCBD", $sformatf("PASS! Input: a=%b, b=%b | Output: sum=%b, carry=%b",
                trans.a, trans.b, trans.s, trans.c), UVM_LOW)
        end
  endfunction
endclass

    
`endif
    
  
  
