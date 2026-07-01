# scripts/vivado_build.tcl
# Tcl script to build the Vivado project, run synthesis & implementation,
# and write the physical programming bitstream (.bit).

set project_name "axi_lite_val_proj"
set project_dir "./vivado_project"
set target_part "xc7a35tftg256-1" ;# Exact part for EDGE Artix-7 board

puts "=================================================="
puts "Initializing Vivado project: $project_name"
puts "=================================================="

# 1. Create project
create_project -force $project_name $project_dir -part $target_part

# 2. Add RTL Design sources
if {[file isdirectory "./rtl"]} {
    add_files [glob ./rtl/*.v]
} else {
    puts "ERROR: RTL directory not found."
    exit 1
}

# 3. Add Constraints
if {[file exists "./constraints/pins.xdc"]} {
    add_files -fileset constrs_1 ./constraints/pins.xdc
} else {
    puts "WARNING: constraints/pins.xdc not found. Skipping pin assignments."
}

# 4. Set top-level module
set_property top top_axi_lite_register_validation [current_fileset]
update_compile_order -fileset sources_1

# 5. Run Synthesis
puts "--------------------------------------------------"
puts "Running Synthesis..."
puts "--------------------------------------------------"
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Check for synthesis success
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "ERROR: Synthesis failed."
    exit 1
}

# 6. Run Implementation and Write Bitstream
puts "--------------------------------------------------"
puts "Running Implementation & Generating Bitstream..."
puts "--------------------------------------------------"
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

# Check for implementation success
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "ERROR: Implementation/Bitstream generation failed."
    exit 1
}

set run_dir [get_property DIRECTORY [current_run]]
puts "=================================================="
puts "Vivado build complete!"
puts "Bitstream generated at: $run_dir/top_axi_lite_register_validation.bit"
puts "=================================================="
exit 0
