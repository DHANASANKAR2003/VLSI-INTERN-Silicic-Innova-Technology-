# test_access_permissions.py
# Verification Test: Exercises and verifies AXI access permissions (RW, RO, WO) across all registers.

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
    
    for block_name, block_info in reg_agent.blocks.items():
        for reg_name, reg_info in block_info['registers'].items():
            mode = reg_info['mode']
            
            if mode == 'RW':
                # Test RW
                _, status_w = reg_agent.write(block_name, reg_name, 0x1234_5678)
                cov.log_write(block_name, reg_name, 0x1234_5678)
                val, status_r = reg_agent.read(block_name, reg_name)
                cov.log_read(block_name, reg_name, val)
                
                if status_w != "OKAY" or status_r != "OKAY" or val != 0x1234_5678:
                    failures.append(f"RW check failed for {block_name}.{reg_name}")
                    errors += 1
                    
            elif mode == 'RO':
                # Test RO
                orig_val, _ = reg_agent.read(block_name, reg_name)
                cov.log_read(block_name, reg_name, orig_val)
                # Write attempt
                reg_agent.write(block_name, reg_name, 0x9999_9999)
                cov.log_write(block_name, reg_name, 0x9999_9999)
                # Read check
                val, _ = reg_agent.read(block_name, reg_name)
                cov.log_read(block_name, reg_name, val)
                
                if val != orig_val:
                    failures.append(f"RO violation: {block_name}.{reg_name} modified. Orig: 0x{orig_val:X}, Got: 0x{val:X}")
                    errors += 1
                    
            elif mode == 'WO':
                # Test WO
                _, status_w = reg_agent.write(block_name, reg_name, 0xAAAA_BBBB)
                cov.log_write(block_name, reg_name, 0xAAAA_BBBB)
                val, status_r = reg_agent.read(block_name, reg_name)
                cov.log_read(block_name, reg_name, val)
                
                if status_w != "OKAY" or status_r != "OKAY":
                    failures.append(f"WO transactions failed for {block_name}.{reg_name}")
                    errors += 1
                elif val != 0:
                    failures.append(f"WO violation: reading {block_name}.{reg_name} returned non-zero value 0x{val:X}")
                    errors += 1

    if errors == 0:
        return True, "All access permissions (RW, RO, WO) verified successfully."
    else:
        return False, "; ".join(failures)

if __name__ == '__main__':
    model_path = os.path.join(os.path.dirname(__file__), 'register_model.yaml')
    driver = SerialDriver(port="MOCK", baudrate=115200, mock_mode=True)
    driver.open()
    axi_agent = AxiLiteAgent(driver)
    reg_agent = RegisterAgent(axi_agent, model_path)
    cov = CoverageCollector(reg_agent.model)
    
    print("Running test_access_permissions...")
    success, notes = run_test(reg_agent, cov)
    print(f"Result: {'PASSED' if success else 'FAILED'} - {notes}")
    driver.close()
