# run_adder_sub_regression.py
# Simplified regression test runner for 5 addition and 5 subtraction tests using YAML test vectors.

import os
import sys
import argparse
import time
import yaml

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from serial_driver import SerialDriver
from report_generator import ReportGenerator

def parse_yaml_value(val):
    if isinstance(val, str):
        val = val.strip()
        if "'b" in val:
            return int(val.split("'b")[1], 2)
        elif val.startswith("0b"):
            return int(val[2:], 2)
    return int(val)

def run_regression(port):
    print("==================================================")
    print("STARTING 8-BIT ADDER/SUBTRACTOR SIMPLIFIED REGRESSION")
    print("==================================================")
    print(f"Port:       {port}")
    print("--------------------------------------------------")
    
    # Load test vectors and protocol specification from YAML
    yaml_path = os.path.join(os.path.dirname(__file__), 'register_model.yaml')
    print(f"Loading register model and test vectors from: {yaml_path}")
    with open(yaml_path, 'r') as f:
        model = yaml.safe_load(f)
        
    tests = model['test_vectors']
    print(f"Loaded {len(tests)} test vectors successfully.")
    print("--------------------------------------------------")
    
    driver = SerialDriver(port=port, baudrate=115200)
    if not driver.open():
        sys.exit(1)
        
    test_results = []

    for i, tc in enumerate(tests):
        tc_num = i + 1
        
        # Parse inputs and expected values from Verilog syntax to integers
        a = parse_yaml_value(tc['a'])
        b = parse_yaml_value(tc['b'])
        ctrl = parse_yaml_value(tc['ctrl'])
        exp_res = parse_yaml_value(tc['exp_res'])
        exp_cb = parse_yaml_value(tc['exp_cb'])
        
        name = f"TC-{tc_num:02d}: {tc['type']} ({a} {'+' if ctrl==0 else '-'} {b})"
        print(f"Running {name}...")
        start_time = time.time()
        
        # Send 3 bytes: [A, B, CTRL]
        resp = driver.write_packet(bytes([a, b, ctrl]))
        duration = time.time() - start_time
        
        if len(resp) < 2:
            status = "FAILED"
            notes = f"Timeout: Received {len(resp)} bytes, expected 2."
            actual_res, actual_cb = 0, 0
        else:
            actual_res = resp[0]
            actual_cb = resp[1]
            
            passed = (actual_res == exp_res) and (actual_cb == exp_cb)
            status = "PASSED" if passed else "FAILED"
            
            op_symbol = "+" if ctrl == 0 else "-"
            cb_label = "Carry" if ctrl == 0 else "Borrow"
            
            notes = (
                f"<b>Inputs:</b> A = {a} (8'b{a:08b}), B = {b} (8'b{b:08b}), CTRL = {ctrl} (1'b{ctrl:b}) ({tc['type']})<br/>"
                f"<b>Expected Result:</b> 8'b{exp_res:08b} ({cb_label}: 1'b{exp_cb:b})<br/>"
                f"<b>Actual Result:</b> 8'b{actual_res:08b} ({cb_label}: 1'b{actual_cb:b})"
            )
            
        test_results.append({
            "name": name,
            "description": tc['desc'],
            "status": status,
            "duration": duration,
            "notes": notes
        })
        
        print(f"Result:  {status} ({duration:.4f}s)")
        print(f"Details: A = {a} (8'b{a:08b}) {op_symbol} B = {b} (8'b{b:08b}) | CTRL = {ctrl} (1'b{ctrl:b})")
        print(f"         Expected Result: 8'b{exp_res:08b} ({cb_label}: 1'b{exp_cb:b})")
        print(f"         Actual Result:   8'b{actual_res:08b} ({cb_label}: 1'b{actual_cb:b})")
        print("--------------------------------------------------")

    driver.close()
    
    # Generate HTML Report
    parent_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    html_report_path = os.path.join(parent_dir, 'report.html')
    
    print("Generating validation reports...")
    rep_gen = ReportGenerator(test_results)
    rep_gen.generate_html(html_report_path)
    
    print("==================================================")
    print("REGRESSION COMPLETED SUMMARY")
    print("==================================================")
    print(f"Tests Run:  {len(test_results)}")
    print(f"Passed:     {sum(1 for t in test_results if t['status'] == 'PASSED')} / {len(test_results)}")
    print(f"Reports saved in: {parent_dir}")
    print("==================================================")

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', type=str, default='MOCK', help='Serial port (e.g. COM7 or MOCK)')
    args = parser.parse_args()
    
    run_regression(args.port)
