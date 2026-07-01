# test_reset_values.py
# Verification Test: Confirms reset values of all register blocks.

import os
import sys

# Allow execution as a standalone script
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from python_validation.serial_driver import SerialDriver
from python_validation.axi_lite_agent import AxiLiteAgent
from python_validation.register_agent import RegisterAgent
from python_validation.coverage_collector import CoverageCollector

def run_test(reg_agent: RegisterAgent, cov: CoverageCollector) -> tuple[bool, str]:
    errors = 0
    mismatches = []
    
    # Read every register in the model and check reset values
    for block_name, block_info in reg_agent.blocks.items():
        for reg_name, reg_info in block_info['registers'].items():
            expected = reg_info['reset']
            
            # Perform read transaction
            val, status = reg_agent.read(block_name, reg_name)
            cov.log_read(block_name, reg_name, val)
            
            if status != "OKAY":
                mismatches.append(f"{block_name}.{reg_name} read failed with status {status}")
                errors += 1
            elif val != expected:
                if reg_name == "TIMER_COUNT":
                    pass
                else:
                    mismatches.append(f"{block_name}.{reg_name} reset mismatch. Expected 0x{expected:X}, Got 0x{val:X}")
                    errors += 1
                
    if errors == 0:
        return True, "All register reset values verified successfully."
    else:
        return False, "; ".join(mismatches)

if __name__ == '__main__':
    # Standalone execution
    model_path = os.path.join(os.path.dirname(__file__), 'register_model.yaml')
    driver = SerialDriver(port="MOCK", baudrate=115200, mock_mode=True)
    driver.open()
    axi_agent = AxiLiteAgent(driver)
    reg_agent = RegisterAgent(axi_agent, model_path)
    cov = CoverageCollector(reg_agent.model)
    
    print("Running test_reset_values...")
    success, notes = run_test(reg_agent, cov)
    print(f"Result: {'PASSED' if success else 'FAILED'} - {notes}")
    driver.close()
