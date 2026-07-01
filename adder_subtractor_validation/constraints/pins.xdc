## constraints/pins.xdc
## Pin assignments for the Lenseup EDGE Artix-7 Board (xc7a35tftg256-1)
## Configured for the 8-Bit Adder/Subtractor project.

# Onboard 50 MHz Clock Oscillator
set_property -dict { PACKAGE_PIN N11   IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports { clk }];

# Reset Pin (Center Push Button pb[4] - goes High when pressed due to pulldown)
# Inverted in top-level RTL wrapper to make it active-low reset.
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { rst_n_pin }];

# USB-UART Interface (Onboard CP2102)
# FPGA RX (receives from PC)
set_property -dict { PACKAGE_PIN D4    IOSTANDARD LVCMOS33 } [get_ports { uart_rx_pin }];
# FPGA TX (transmits to PC)
set_property -dict { PACKAGE_PIN C4    IOSTANDARD LVCMOS33 } [get_ports { uart_tx_pin }];

# Onboard LEDs (8 LEDs used to display result)
set_property -dict { PACKAGE_PIN J3    IOSTANDARD LVCMOS33 } [get_ports { led_pins[0] }];
set_property -dict { PACKAGE_PIN H3    IOSTANDARD LVCMOS33 } [get_ports { led_pins[1] }];
set_property -dict { PACKAGE_PIN J1    IOSTANDARD LVCMOS33 } [get_ports { led_pins[2] }];
set_property -dict { PACKAGE_PIN K1    IOSTANDARD LVCMOS33 } [get_ports { led_pins[3] }];
set_property -dict { PACKAGE_PIN L3    IOSTANDARD LVCMOS33 } [get_ports { led_pins[4] }];
set_property -dict { PACKAGE_PIN L2    IOSTANDARD LVCMOS33 } [get_ports { led_pins[5] }];
set_property -dict { PACKAGE_PIN K3    IOSTANDARD LVCMOS33 } [get_ports { led_pins[6] }];
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { led_pins[7] }];
