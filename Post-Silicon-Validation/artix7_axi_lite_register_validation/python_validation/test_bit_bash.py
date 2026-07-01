# test_bit_bash.py
# Verification Test: Walks 1s and 0s through all bits of RW registers to check for stuck-at and bridging faults.

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
            if reg_info['mode'] == 'RW':
                # 1. Walking 1s test
                for bit in range(32):
                    val = 1 << bit
                    # Write
                    _, status_w = reg_agent.write(block_name, reg_name, val)
                    cov.log_write(block_name, reg_name, val)
                    
                    # Read back
                    rd_val, status_r = reg_agent.read(block_name, reg_name)
                    cov.log_read(block_name, reg_name, rd_val)
                    
                    if status_w != "OKAY" or status_r != "OKAY":
                        failures.append(f"{block_name}.{reg_name} transaction failed at walking 1 bit {bit}")
                        errors += 1
                        break
                    elif rd_val != val:
                        failures.append(f"{block_name}.{reg_name} stuck-at or bit toggle failure at bit {bit}. Wrote: 0x{val:08X}, Got: 0x{rd_val:08X}")
                        errors += 1
                        break
                
                if errors > 0:
                    break

                # 2. Walking 0s test
                for bit in range(32):
                    val = (~(1 << bit)) & 0xFFFFFFFF
                    # Write
                    _, status_w = reg_agent.write(block_name, reg_name, val)
                    cov.log_write(block_name, reg_name, val)
                    
                    # Read back
                    rd_val, status_r = reg_agent.read(block_name, reg_name)
                    cov.log_read(block_name, reg_name, rd_val)
                    
                    if status_w != "OKAY" or status_r != "OKAY":
                        failures.append(f"{block_name}.{reg_name} transaction failed at walking 0 bit {bit}")
                        errors += 1
                        break
                    elif rd_val != val:
                        failures.append(f"{block_name}.{reg_name} bit-level short circuit or error at bit {bit}. Wrote: 0x{val:08X}, Got: 0x{rd_val:08X}")
                        errors += 1
                        break
                        
    if errors == 0:
        return True, "All RW registers successfully passed the 32-bit walking 1/0 bit-bash verification."
    else:
        return False, "; ".join(failures)

if __name__ == '__main__':
    model_path = os.path.join(os.path.dirname(__file__), 'register_model.yaml')
    driver = SerialDriver(port="MOCK", baudrate=115200, mock_mode=True)
    driver.open()
    axi_agent = AxiLiteAgent(driver)
    reg_agent = RegisterAgent(axi_agent, model_path)
    cov = CoverageCollector(reg_agent.model)
    
    print("Running test_bit_bash...")
    success, notes = run_test(reg_agent, cov)
    print(f"Result: {'PASSED' if success else 'FAILED'} - {notes}")
    driver.close()
