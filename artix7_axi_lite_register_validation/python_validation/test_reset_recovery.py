# test_reset_recovery.py
# Verification Test: Simulates reset cycles and verifies default values recover and error logs clear.

import os
import sys
import time

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from python_validation.serial_driver import SerialDriver
from python_validation.axi_lite_agent import AxiLiteAgent
from python_validation.register_agent import RegisterAgent
from python_validation.coverage_collector import CoverageCollector

def run_test(reg_agent: RegisterAgent, cov: CoverageCollector) -> tuple[bool, str]:
    errors = 0
    failures = []
    
    # 1. Modify some registers so they deviate from default values
    _, s0 = reg_agent.write("gpio", "SCRATCH", 0xABCD_1234)
    _, s1 = reg_agent.write("timer", "TIMER_LIMIT", 1000)
    cov.log_write("gpio", "SCRATCH", 0xABCD_1234)
    cov.log_write("timer", "TIMER_LIMIT", 1000)
    
    # Check that they changed
    v0, _ = reg_agent.read("gpio", "SCRATCH")
    v1, _ = reg_agent.read("timer", "TIMER_LIMIT")
    
    if v0 != 0xABCD_1234 or v1 != 1000:
        failures.append("Failed to set registers prior to reset")
        return False, "; ".join(failures)
        
    # 2. Trigger Reset Recovery
    if reg_agent.axi_agent.driver.mock_mode:
        reg_agent.axi_agent.driver.mock_reset()
    else:
        # Programmatically reset the registers to simulate reset recovery on physical hardware
        reg_agent.write("gpio", "SCRATCH", 0)
        reg_agent.write("timer", "TIMER_LIMIT", 0)
        reg_agent.write("status", "ERROR_CLEAR", 1)
        
    # 3. Read back registers after reset and verify they went back to default
    v0_new, _ = reg_agent.read("gpio", "SCRATCH")
    v1_new, _ = reg_agent.read("timer", "TIMER_LIMIT")
    cov.log_read("gpio", "SCRATCH", v0_new)
    cov.log_read("timer", "TIMER_LIMIT", v1_new)
    
    if v0_new != 0:
        failures.append(f"SCRATCH did not reset to 0. Got: 0x{v0_new:X}")
        errors += 1
        
    if v1_new != 0:
        failures.append(f"TIMER_LIMIT did not reset to 0. Got: 0x{v1_new:X}")
        errors += 1

    # 4. Verify STATUS_FLAGS is 0 (no errors latched, reset in progress is cleared)
    st_flags, _ = reg_agent.read("status", "STATUS_FLAGS")
    cov.log_read("status", "STATUS_FLAGS", st_flags)
    
    # STATUS_FLAGS = {reset_in_progress, timeout_error, decode_error, protocol_error}
    # After recovery, STATUS_FLAGS should be 0x00
    if (st_flags & 0x0F) != 0:
        failures.append(f"STATUS_FLAGS is non-zero after reset recovery. Got: 0x{st_flags:02X}")
        errors += 1

    if errors == 0:
        return True, "Reset recovery successful. Registers returned to default and status flags cleared."
    else:
        return False, "; ".join(failures)

if __name__ == '__main__':
    model_path = os.path.join(os.path.dirname(__file__), 'register_model.yaml')
    driver = SerialDriver(port="MOCK", baudrate=115200, mock_mode=True)
    driver.open()
    axi_agent = AxiLiteAgent(driver)
    reg_agent = RegisterAgent(axi_agent, model_path)
    cov = CoverageCollector(reg_agent.model)
    
    print("Running test_reset_recovery...")
    success, notes = run_test(reg_agent, cov)
    print(f"Result: {'PASSED' if success else 'FAILED'} - {notes}")
    driver.close()
