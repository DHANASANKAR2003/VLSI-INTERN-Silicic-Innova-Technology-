# test_read_write.py
# Verification Test: Validates basic write/read cycles to RW registers.

import os
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from python_validation.serial_driver import SerialDriver
from python_validation.axi_lite_agent import AxiLiteAgent
from python_validation.register_agent import RegisterAgent
from python_validation.coverage_collector import CoverageCollector

def run_test(reg_agent: RegisterAgent, cov: CoverageCollector) -> tuple[bool, str]:
    errors = 0
    failures = []
    
    # Test values to write
    test_patterns = [0x55555555, 0xAAAAAAAA, 0x12345678, 0x00000000, 0xFFFFFFFF]
    
    # Write and read back to every RW register in the model
    for block_name, block_info in reg_agent.blocks.items():
        for reg_name, reg_info in block_info['registers'].items():
            if reg_info['mode'] == 'RW':
                for val in test_patterns:
                    # Write
                    _, w_status = reg_agent.write(block_name, reg_name, val)
                    cov.log_write(block_name, reg_name, val)
                    
                    # Read back
                    rd_val, r_status = reg_agent.read(block_name, reg_name)
                    cov.log_read(block_name, reg_name, rd_val)
                    
                    if w_status != "OKAY" or r_status != "OKAY":
                        failures.append(f"{block_name}.{reg_name} transaction failed. Write: {w_status}, Read: {r_status}")
                        errors += 1
                        break
                    elif rd_val != val:
                        failures.append(f"{block_name}.{reg_name} write/read mismatch. Wrote: 0x{val:08X}, Read: 0x{rd_val:08X}")
                        errors += 1
                        break
                        
    if errors == 0:
        return True, "All RW registers verified successfully."
    else:
        return False, "; ".join(failures)

if __name__ == '__main__':
    model_path = os.path.join(os.path.dirname(__file__), 'register_model.yaml')
    driver = SerialDriver(port="MOCK", baudrate=115200, mock_mode=True)
    driver.open()
    axi_agent = AxiLiteAgent(driver)
    reg_agent = RegisterAgent(axi_agent, model_path)
    cov = CoverageCollector(reg_agent.model)
    
    print("Running test_read_write...")
    success, notes = run_test(reg_agent, cov)
    print(f"Result: {'PASSED' if success else 'FAILED'} - {notes}")
    driver.close()
