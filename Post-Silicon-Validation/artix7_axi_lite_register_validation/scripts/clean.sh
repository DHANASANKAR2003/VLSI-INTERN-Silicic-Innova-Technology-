#!/bin/bash
# scripts/clean.sh
# Cleans temporary logs, simulation directories, and Vivado project files.

# Locate script path and navigate to project root
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPTS_DIR")"
cd "$PROJECT_DIR" || exit 1

echo "=================================================="
echo "Cleaning validation logs, simulation, and Vivado..."
echo "=================================================="

# 1. Clean testbench simulation outputs
rm -f *.vvp *.log
rm -f tb/*.log

# 2. Clean python regression logs, reports, and compiled bytecode cache
rm -f report.md report.html dashboard.html
rm -f python_validation/*.log
rm -rf python_validation/__pycache__
rm -rf __pycache__

# 3. Clean Vivado temporary run files and projects
rm -rf .Xil/
rm -rf vivado_project/
rm -f vivado*.log vivado*.jou
rm -f xsim*.log xsim*.jou
rm -f webtalk*.log webtalk*.jou

echo "Cleanup completed successfully."
echo "=================================================="
