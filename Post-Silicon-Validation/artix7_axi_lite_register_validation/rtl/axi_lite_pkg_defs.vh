// axi_lite_pkg_defs.vh
// Shared packet-format and opcode definitions for the UART <-> AXI-Lite bridge.
// Included by uart_register_interface.v and axi_lite_master_cmd_if.v so both
// sides agree on the wire format without needing a SystemVerilog package.
//
// Packet format (host -> FPGA), 7 bytes per command:
//   [0]      OPCODE   (8'h57 = WRITE, 8'h52 = READ)
//   [1:4]    ADDRESS  (32-bit, MSB first)
//   [5:8]    DATA     (32-bit, MSB first, only meaningful for WRITE)
//   (READ commands omit DATA bytes - host sends 5 bytes total for a read)
//
// Response format (FPGA -> host), 6 bytes per response:
//   [0]      STATUS   (8'h00 = OKAY, 8'h01 = SLVERR, 8'h02 = DECERR, 8'h03 = TIMEOUT)
//   [1:4]    DATA     (32-bit read data, or echoed write data, MSB first)
//   [5]      RESP_TYPE (8'h57 = write ack, 8'h52 = read ack)

`ifndef AXI_LITE_PKG_DEFS_VH
`define AXI_LITE_PKG_DEFS_VH

`define OPCODE_WRITE   8'h57   // ASCII 'W'
`define OPCODE_READ    8'h52   // ASCII 'R'

`define RESP_OKAY      8'h00
`define RESP_SLVERR    8'h01
`define RESP_DECERR    8'h02
`define RESP_TIMEOUT   8'h03

`define AXI_RESP_OKAY   2'b00
`define AXI_RESP_EXOKAY 2'b01
`define AXI_RESP_SLVERR 2'b10
`define AXI_RESP_DECERR 2'b11

`endif
