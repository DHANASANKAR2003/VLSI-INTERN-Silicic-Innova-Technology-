#!/bin/bash
# run_tests.sh
# Compile and run the SystemVerilog testbenches using Icarus Verilog (iverilog)

SIM_DIR="/Users/dhanasankark/.gemini/antigravity/scratch"
cd "$SIM_DIR"

echo "=================================================="
echo "RUNNING AXI-LITE REGISTER VALIDATION TEST SUITE"
echo "=================================================="

testbenches=(
  "tb_axi_lite_register_block"
  "tb_axi_lite_master_cmd_if"
  "tb_axi_lite_protocol_checker"
  "tb_axi_lite_error_injector"
  "tb_register_access_monitor"
  "tb_top_axi_lite_register_validation"
)

failed=0

for tb in "${testbenches[@]}"; do
  echo ""
  echo "--------------------------------------------------"
  echo "Executing: $tb"
  echo "--------------------------------------------------"
  
  # Clean up old compilation files
  rm -f "${tb}.vvp"
  
  # Choose files based on target module
  if [ "$tb" == "tb_top_axi_lite_register_validation" ]; then
    /opt/homebrew/bin/iverilog -g2012 -o "${tb}.vvp" -I ./rtl ./rtl/*.v "tb/${tb}.sv"
  elif [ "$tb" == "tb_axi_lite_register_block" ]; then
    /opt/homebrew/bin/iverilog -g2012 -o "${tb}.vvp" -I ./rtl ./rtl/axi_lite_register_block.v "tb/${tb}.sv"
  elif [ "$tb" == "tb_axi_lite_master_cmd_if" ]; then
    /opt/homebrew/bin/iverilog -g2012 -o "${tb}.vvp" -I ./rtl ./rtl/axi_lite_master_cmd_if.v "tb/${tb}.sv"
  elif [ "$tb" == "tb_axi_lite_protocol_checker" ]; then
    /opt/homebrew/bin/iverilog -g2012 -o "${tb}.vvp" -I ./rtl ./rtl/axi_lite_protocol_checker.v "tb/${tb}.sv"
  elif [ "$tb" == "tb_axi_lite_error_injector" ]; then
    /opt/homebrew/bin/iverilog -g2012 -o "${tb}.vvp" -I ./rtl ./rtl/axi_lite_error_injector.v "tb/${tb}.sv"
  elif [ "$tb" == "tb_register_access_monitor" ]; then
    /opt/homebrew/bin/iverilog -g2012 -o "${tb}.vvp" -I ./rtl ./rtl/register_access_monitor.v "tb/${tb}.sv"
  fi
  
  if [ $? -ne 0 ]; then
    echo "RESULT: Compilation failed for $tb"
    failed=$((failed + 1))
    continue
  fi
  
  # Run simulation and capture output
  vvp "${tb}.vvp" > "${tb}.log" 2>&1
  
  # Print log output to shell
  cat "${tb}.log"
  
  # Verify pass status
  if grep -q "FAIL" "${tb}.log" || grep -q "ERROR" "${tb}.log" || ! grep -q "PASS" "${tb}.log"; then
    echo "RESULT: $tb FAILED"
    failed=$((failed + 1))
  else
    echo "RESULT: $tb PASSED"
  fi
done

echo ""
echo "=================================================="
echo "TEST SUITE COMPLETED: $((6 - failed)) PASSED, $failed FAILED"
echo "=================================================="

# Clean up temporary vvp executables
rm -f *.vvp

if [ $failed -eq 0 ]; then
  exit 0
else
  exit 1
fi
