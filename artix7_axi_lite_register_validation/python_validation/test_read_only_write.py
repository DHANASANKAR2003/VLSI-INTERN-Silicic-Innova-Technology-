# test_read_only_write.py
# Verification Test: Confirms writes to RO registers are dropped and do not modify values.

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
    
    # Try to write non-zero value to every RO register and check that read remains identical
    for block_name, block_info in reg_agent.blocks.items():
        for reg_name, reg_info in block_info['registers'].items():
            if reg_info['mode'] == 'RO':
                # Read baseline first
                orig_val, r_status1 = reg_agent.read(block_name, reg_name)
                cov.log_read(block_name, reg_name, orig_val)
                
                # Attempt to write different value
                test_val = 0xAA55AA55 if orig_val != 0xAA55AA55 else 0x55AA55AA
                _, w_status = reg_agent.write(block_name, reg_name, test_val)
                cov.log_write(block_name, reg_name, test_val)
                
                # Read back
                new_val, r_status2 = reg_agent.read(block_name, reg_name)
                cov.log_read(block_name, reg_name, new_val)
                
                if w_status != "OKAY" or r_status1 != "OKAY" or r_status2 != "OKAY":
                    failures.append(f"{block_name}.{reg_name} transaction failed during RO test")
                    errors += 1
                elif new_val != orig_val:
                    if reg_name == "TIMER_COUNT":
                        if new_val == test_val:
                            failures.append(f"ERROR: {block_name}.{reg_name} (RO) was successfully modified by write to: 0x{test_val:08X}")
                            errors += 1
                    else:
                        failures.append(f"ERROR: {block_name}.{reg_name} (RO) modified by write. Orig: 0x{orig_val:08X}, New: 0x{new_val:08X}")
                        errors += 1
                    
    if errors == 0:
        return True, "RO register write policy verified successfully (all writes ignored)."
    else:
        return False, "; ".join(failures)

if __name__ == '__main__':
    model_path = os.path.join(os.path.dirname(__file__), 'register_model.yaml')
    driver = SerialDriver(port="MOCK", baudrate=115200, mock_mode=True)
    driver.open()
    axi_agent = AxiLiteAgent(driver)
    reg_agent = RegisterAgent(axi_agent, model_path)
    cov = CoverageCollector(reg_agent.model)
    
    print("Running test_read_only_write...")
    success, notes = run_test(reg_agent, cov)
    print(f"Result: {'PASSED' if success else 'FAILED'} - {notes}")
    driver.close()
