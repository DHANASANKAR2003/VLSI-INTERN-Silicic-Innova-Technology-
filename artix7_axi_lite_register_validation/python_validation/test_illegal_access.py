# test_illegal_access.py
# Verification Test: Accesses out-of-bounds and unaligned addresses to check that DECERR/SLVERR are correctly raised.

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
    
    # 1. Test unmapped address decoding (DECERR check)
    unmapped_addr = 0x0000_0300 # Out of bounds base range
    
    # Read unmapped
    _, rd_status = reg_agent.axi_agent.read(unmapped_addr)
    # Write unmapped
    _, wr_status = reg_agent.axi_agent.write(unmapped_addr, 0x1234_5678)
    
    if rd_status != "DECERR":
        failures.append(f"Unmapped read did not raise DECERR. Got status: {rd_status}")
        errors += 1
        
    if wr_status != "DECERR":
        failures.append(f"Unmapped write did not raise DECERR. Got status: {wr_status}")
        errors += 1

    # 2. Test unaligned address folding (RTL folds address offsets to multiples of 4)
    unaligned_addr = 0x0000_0002 # Unaligned (should fold to 0x0000_0000 = GPIO_OUT)
    
    test_val = 0x5555_AAAA
    _, al_wr_status = reg_agent.axi_agent.write(unaligned_addr, test_val)
    
    # Read back from aligned address 0x0000 (GPIO_OUT) to verify it updated
    rd_val, al_rd_status = reg_agent.axi_agent.read(0x0000_0000)
    cov.log_read("gpio", "GPIO_OUT", rd_val)
    
    if al_wr_status != "OKAY" or al_rd_status != "OKAY":
        failures.append(f"Unaligned access transaction failed. Write: {al_wr_status}, Read: {al_rd_status}")
        errors += 1
    elif rd_val != test_val:
        failures.append(f"Unaligned address offset did not fold to aligned base register. Expected: 0x{test_val:X}, Got: 0x{rd_val:X}")
        errors += 1

    if errors == 0:
        return True, "Interconnect correctly rejected unmapped requests with DECERR and handled unaligned offsets via address folding."
    else:
        return False, "; ".join(failures)

if __name__ == '__main__':
    model_path = os.path.join(os.path.dirname(__file__), 'register_model.yaml')
    driver = SerialDriver(port="MOCK", baudrate=115200, mock_mode=True)
    driver.open()
    axi_agent = AxiLiteAgent(driver)
    reg_agent = RegisterAgent(axi_agent, model_path)
    cov = CoverageCollector(reg_agent.model)
    
    print("Running test_illegal_access...")
    success, notes = run_test(reg_agent, cov)
    print(f"Result: {'PASSED' if success else 'FAILED'} - {notes}")
    driver.close()
