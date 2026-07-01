# scripts/program_fpga.tcl
# Tcl script to program the Artix-7 FPGA board using the Vivado Hardware Manager.

set bitstream_path "./vivado_project/axi_lite_val_proj.runs/impl_1/top_axi_lite_register_validation.bit"

puts "=================================================="
puts "Connecting to FPGA Hardware Target..."
puts "=================================================="

# 1. Open Hardware Manager
open_hw_manager

# 2. Connect to local Hardware Server
connect_hw_server -allow_non_jtag -url localhost:3121
refresh_hw_server

# 3. Open JTAG Target (cable link)
if {[catch {open_hw_target} err]} {
    puts "ERROR: Failed to open hardware target: $err"
    puts "Please ensure your JTAG USB programming cable is connected and powered."
    exit 1
}

# 4. Grab device node (assuming first JTAG device is the Artix-7 chip)
set device [lindex [get_hw_devices] 0]
current_hw_device $device
refresh_hw_device -update_hw_probes false $device

# 5. Program bitstream
if {[file exists $bitstream_path]} {
    puts "Programming device $device with $bitstream_path..."
    set_property PROGRAM.FILE $bitstream_path $device
    program_hw_devices $device
    refresh_hw_device $device
    puts "=================================================="
    puts "SUCCESS: FPGA programmed successfully!"
    puts "=================================================="
    exit 0
} else {
    puts "ERROR: Bitstream file not found at $bitstream_path."
    puts "Please run the Vivado build flow first (vivado_build.tcl)."
    exit 1
}
