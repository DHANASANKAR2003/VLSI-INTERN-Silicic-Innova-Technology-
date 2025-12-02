`ifndef HA_TRANSACTION_SV
`define HA_TRANSACTION_SV

import uvm_pkg::*;          
`include "uvm_macros.svh"  


class ha_transaction extends uvm_sequence_item;
  `uvm_object_utils(ha_transaction)
  
  rand bit a;
  rand bit b;
  
  bit s;
  bit c;
  
  function new(string name = "ha_transaction");
    super.new(name);
  endfunction
  
  function string convert2string();
    return $sformatf("INPUT A = %d \t B = %d \t OUTPUT SUM = %d \t CARRY = %d \n",a, b, s, c);
  endfunction
endclass

`endif
