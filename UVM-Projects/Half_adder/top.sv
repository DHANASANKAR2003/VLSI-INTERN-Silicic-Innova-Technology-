`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"

`include "interface.sv"
`include "test.sv"
//`include "half_adder.sv"

module top;
  
  ha_interface intf();
  
  half_adder dut (
    .a(intf.a),
    .b(intf.b),
    .s(intf.s),
    .c(intf.c)
  );
  initial begin
    uvm_config_db#(virtual ha_interface)::set(null, "*", "vif", intf);
    run_test("ha_test");
  end
  
  initial begin
    $dumpfile("half_adder.vcd");
    $dumpvars(0,top);
  end
endmodule
