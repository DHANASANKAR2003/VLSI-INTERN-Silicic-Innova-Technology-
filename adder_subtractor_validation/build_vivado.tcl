################################################################################
# build_vivado.tcl
# Non-project (batch) mode Vivado build script for the 8-Bit Adder/Subtractor
# UART project, targeting:
#   FPGA Part : xc7a35tftg256-1
#   Board     : Edge Artix-7 (Arty A7-35T class board)
#
# Usage:
#   vivado -mode batch -source build_vivado.tcl
#
# This script will:
#   1. Create a fresh project (in-memory, non-project flow)
#   2. Add all RTL sources
#   3. Add the constraints (.xdc) file
#   4. Run synthesis
#   5. Run implementation (place & route)
#   6. Generate the bitstream
#   7. Write reports (timing, utilization)
#
# NOTE: Edit SRC_FILES and CONSTR_FILE below if your file names/paths differ.
################################################################################

# ------------------------------------------------------------------------
# 1. Project / part settings
# ------------------------------------------------------------------------
set PART        "xc7a35tftg256-1"
set TOP_MODULE  "top_adder_subtractor"
set OUTPUT_DIR  "./build"
set BIT_FILE    "${OUTPUT_DIR}/${TOP_MODULE}.bit"

# RTL source files (edit paths if your sources live elsewhere)
set SRC_FILES [list \
    "./uart_rx.v" \
    "./uart_tx.v" \
    "./uart_register_interface.v" \
    "./top_adder_subtractor.v" \
]

# Constraints file - create/edit this to match your board's pin assignments
# (clock pin, reset button, UART RX/TX pins, LED pins)
set CONSTR_FILE "./constraints.xdc"

# ------------------------------------------------------------------------
# 2. Clean / create output directory
# ------------------------------------------------------------------------
file mkdir $OUTPUT_DIR

# ------------------------------------------------------------------------
# 3. Read design sources
# ------------------------------------------------------------------------
puts "INFO: Reading RTL sources..."
foreach f $SRC_FILES {
    if {![file exists $f]} {
        puts "ERROR: Source file not found: $f"
        exit 1
    }
    read_verilog $f
}

# ------------------------------------------------------------------------
# 4. Read constraints
# ------------------------------------------------------------------------
if {[file exists $CONSTR_FILE]} {
    puts "INFO: Reading constraints file: $CONSTR_FILE"
    read_xdc $CONSTR_FILE
} else {
    puts "WARNING: Constraints file '$CONSTR_FILE' not found."
    puts "WARNING: Continuing without constraints - implementation will likely"
    puts "WARNING: fail or produce an unusable bitstream without pin/clock LOCs."
}

# ------------------------------------------------------------------------
# 5. Synthesis
# ------------------------------------------------------------------------
puts "INFO: Running synthesis for part $PART, top module $TOP_MODULE..."
synth_design -top $TOP_MODULE -part $PART

write_checkpoint -force "${OUTPUT_DIR}/post_synth.dcp"
report_timing_summary -file "${OUTPUT_DIR}/post_synth_timing_summary.rpt"
report_utilization    -file "${OUTPUT_DIR}/post_synth_utilization.rpt"

# ------------------------------------------------------------------------
# 6. Implementation (opt -> place -> physopt -> route)
# ------------------------------------------------------------------------
puts "INFO: Running implementation (opt_design)..."
opt_design

puts "INFO: Running implementation (place_design)..."
place_design

puts "INFO: Running implementation (phys_opt_design)..."
phys_opt_design

puts "INFO: Running implementation (route_design)..."
route_design

write_checkpoint -force "${OUTPUT_DIR}/post_route.dcp"
report_timing_summary -file "${OUTPUT_DIR}/post_route_timing_summary.rpt"
report_utilization    -file "${OUTPUT_DIR}/post_route_utilization.rpt"
report_drc            -file "${OUTPUT_DIR}/post_route_drc.rpt"

# ------------------------------------------------------------------------
# 7. Check timing before generating bitstream
# ------------------------------------------------------------------------
set wns [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
if {$wns < 0} {
    puts "WARNING: Design did NOT meet timing! Worst negative slack = $wns ns"
    puts "WARNING: Bitstream will still be generated, but review timing reports."
} else {
    puts "INFO: Timing met. Worst slack = $wns ns"
}

# ------------------------------------------------------------------------
# 8. Generate bitstream
# ------------------------------------------------------------------------
puts "INFO: Writing bitstream to $BIT_FILE ..."
write_bitstream -force $BIT_FILE

puts "=================================================================="
puts "BUILD COMPLETE"
puts "Bitstream: $BIT_FILE"
puts "Reports:   $OUTPUT_DIR"
puts "=================================================================="
