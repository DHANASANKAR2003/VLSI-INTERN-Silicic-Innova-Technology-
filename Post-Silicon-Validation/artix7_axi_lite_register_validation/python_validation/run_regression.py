# run_regression.py
# Main regression execution script. Runs all validation test cases,
# aggregates outcomes, calculates coverage, and outputs reports.

import os
import sys
import time

# Ensure we can import modules in this directory and parent directory
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from serial_driver import SerialDriver
from axi_lite_agent import AxiLiteAgent
from register_agent import RegisterAgent
from coverage_collector import CoverageCollector
from report_generator import ReportGenerator
from dashboard import generate_dashboard

# Test script imports
import test_reset_values
import test_read_write
import test_read_only_write
import test_access_permissions
import test_bit_bash
import test_illegal_access
import test_reset_recovery

def parse_board_config(filepath: str) -> dict:
    """Lightweight board configuration YAML parser."""
    config = {'serial': {'port': '/dev/tty.usbserial-10', 'baudrate': 115200, 'timeout': 1.0, 'mock_mode': True}}
    if not os.path.exists(filepath):
        return config
    with open(filepath, 'r') as f:
        for line in f:
            # Strip comments first
            line = line.split('#', 1)[0].strip()
            if not line:
                continue
            if ':' in line:
                key, val = line.split(':', 1)
                key = key.strip()
                val = val.strip().strip('"')
                if key == 'port':
                    config['serial']['port'] = val
                elif key == 'baudrate':
                    config['serial']['baudrate'] = int(val)
                elif key == 'timeout':
                    config['serial']['timeout'] = float(val)
                elif key == 'mock_mode':
                    config['serial']['mock_mode'] = (val.lower() == 'true')
    return config

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    board_cfg_path = os.path.join(script_dir, 'board_config.yaml')
    reg_model_path = os.path.join(script_dir, 'register_model.yaml')
    
    # 1. Load configurations
    cfg = parse_board_config(board_cfg_path)
    
    # Override configuration via command-line arguments if present
    for i in range(1, len(sys.argv)):
        if sys.argv[i] == '--port' and i + 1 < len(sys.argv):
            cfg['serial']['port'] = sys.argv[i+1]
            cfg['serial']['mock_mode'] = False
        elif sys.argv[i] == '--mock':
            cfg['serial']['mock_mode'] = True
    
    print("==================================================")
    print("STARTING AXI-LITE REGISTER VALIDATION REGRESSION")
    print("==================================================")
    print(f"Port:       {cfg['serial']['port']}")
    print(f"Baudrate:   {cfg['serial']['baudrate']}")
    print(f"Mock Mode:  {cfg['serial']['mock_mode']}")
    print("--------------------------------------------------")

    # 2. Initialize Driver and Agents
    driver = SerialDriver(
        port=cfg['serial']['port'],
        baudrate=cfg['serial']['baudrate'],
        timeout=cfg['serial']['timeout'],
        mock_mode=cfg['serial']['mock_mode']
    )
    
    if not driver.open():
        print("ERROR: Could not open connection. Aborting regression.")
        sys.exit(1)

    axi_agent = AxiLiteAgent(driver)
    reg_agent = RegisterAgent(axi_agent, reg_model_path)
    cov_collector = CoverageCollector(reg_agent.model)

    # 3. List of tests to execute
    tests = [
        {
            "name": "TC-01: Reset Values Verification",
            "description": "Checks initial register values against default YAML settings.",
            "module": test_reset_values
        },
        {
            "name": "TC-02: Write/Read Back RW Registers",
            "description": "Verifies write and read cycles on RW fields.",
            "module": test_read_write
        },
        {
            "name": "TC-03: Read-Only Registers Write Check",
            "description": "Verifies that writes to RO registers are dropped.",
            "module": test_read_only_write
        },
        {
            "name": "TC-04: RW / RO / WO Permission Verification",
            "description": "Tests read and write constraints per register type.",
            "module": test_access_permissions
        },
        {
            "name": "TC-05: 32-Bit Toggle Bit-Bash Sweep",
            "description": "Executes walking 1/0 checks on all RW bits.",
            "module": test_bit_bash
        },
        {
            "name": "TC-06: Out-of-Bounds Address Decoding (DECERR)",
            "description": "Validates error status for illegal address spaces.",
            "module": test_illegal_access
        },
        {
            "name": "TC-07: Reset Recovery Check",
            "description": "Simulates soft resets and checks post-reset stability.",
            "module": test_reset_recovery
        }
    ]

    # Initialize all RW registers to 0 before starting regression on hardware
    if not driver.mock_mode:
        print("Initializing hardware registers to default states...")
        reg_agent.write("gpio", "GPIO_OUT", 0)
        reg_agent.write("gpio", "GPIO_DIR", 0)
        reg_agent.write("gpio", "SCRATCH", 0)
        reg_agent.write("timer", "TIMER_CTRL", 0)
        reg_agent.write("timer", "TIMER_LIMIT", 0)
        reg_agent.write("status", "ERROR_CLEAR", 1)

    test_results = []
    failed_any = False

    # 4. Run tests sequentially
    for t in tests:
        if driver.mock_mode:
            driver.mock_reset()
        print(f"Running {t['name']}...")
        start_time = time.time()
        
        try:
            passed, notes = t['module'].run_test(reg_agent, cov_collector)
            status = "PASSED" if passed else "FAILED"
        except Exception as e:
            passed = False
            status = "ERROR"
            notes = f"Exception occurred: {str(e)}"
            import traceback
            traceback.print_exc()

        duration = time.time() - start_time
        print(f"Result:  {status} ({duration:.3f}s)")
        print(f"Notes:   {notes}")
        print("--------------------------------------------------")

        test_results.append({
            "name": t['name'],
            "description": t['description'],
            "status": status,
            "duration": duration,
            "notes": notes
        })

        if status != "PASSED":
            failed_any = True

    # 5. Close Driver connection
    driver.close()

    # 6. Calculate Coverage Metrics
    cov_summary = cov_collector.calculate_coverage()

    # 7. Generate Reports & Dashboard
    parent_dir = os.path.dirname(script_dir)
    md_report_path = os.path.join(parent_dir, 'report.md')
    html_report_path = os.path.join(parent_dir, 'report.html')
    dashboard_path = os.path.join(parent_dir, 'dashboard.html')

    print("Generating validation reports...")
    rep_gen = ReportGenerator(test_results, cov_summary)
    rep_gen.generate_markdown(md_report_path)
    rep_gen.generate_html(html_report_path)
    generate_dashboard(dashboard_path, test_results, cov_summary)

    # Automatically open the generated HTML report in the default browser
    import webbrowser
    webbrowser.open(os.path.abspath(html_report_path))

    print("==================================================")
    print("REGRESSION COMPLETED SUMMARY")
    print("==================================================")
    passed_cnt = sum(1 for tr in test_results if tr['status'] == "PASSED")
    print(f"Tests Run:  {len(test_results)}")
    print(f"Passed:     {passed_cnt} / {len(test_results)}")
    print(f"Access Coverage: {cov_summary['overall_access_percent']:.1f}%")
    print(f"Bit-Bash Coverage: {cov_summary['overall_bit_percent']:.1f}%")
    print(f"Reports saved in: {parent_dir}")
    print("==================================================")

    if failed_any:
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == '__main__':
    main()
