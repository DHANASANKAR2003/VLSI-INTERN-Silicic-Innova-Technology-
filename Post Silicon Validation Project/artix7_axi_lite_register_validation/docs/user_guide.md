# AXI-Lite Validation Framework User Guide & Troubleshooting Manual

This guide describes how to run and debug the AXI-Lite Register Validation system.

---

## 1. Prerequisites and Installation

The validation suite uses Python 3 along with YAML configuration files and serial port drivers.

### Install Dependencies
Run the following command in your terminal to install the required libraries:
```bash
pip3 install pyyaml pyserial
```

*Note: If `pyserial` is not installed, the python scripts will automatically fall back to **Mock Mode (Dry-Run)**, allowing you to test the automation locally without a physical FPGA board.*

---

## 2. Compilation and Board Programming

### A. Synthesis and Bitstream Generation (Vivado)
To compile the Verilog source code and map it to the physical FPGA pins, run the build script in Vivado:
1. Open the Vivado GUI.
2. In the Tcl Console at the bottom, enter:
   ```tcl
   cd "/Users/dhanasankark/.gemini/antigravity/scratch/edge_register_validation"
   source scripts/vivado_build.tcl
   ```
3. Wait for the compilation to complete. This creates a `./vivado_project` folder and generates a bitstream file at:
   `./vivado_project/axi_lite_val_proj.runs/impl_1/top_axi_lite_register_validation.bit`

### B. Program the FPGA Board
1. Plug the micro-USB cable into the JTAG port of the **EDGE Artix-7** board.
2. Toggle the power switch (SW2) to turn the board ON.
3. In the Vivado Tcl Console, execute:
   ```tcl
   source scripts/program_fpga.tcl
   ```

---

## 3. Running Register Validation

### Step 1: Identify your Virtual COM Port
When you plug in the board, your operating system registers a new COM port:
* **Windows**: Open *Device Manager*, expand *Ports (COM & LPT)*, and note the COM number (e.g. `COM3`).
* **macOS**: Open Terminal and run:
  ```bash
  ls /dev/tty.usbserial*
  ```
* **Linux**: Open Terminal and run:
  ```bash
  ls /dev/ttyUSB*
  ```

### Step 2: Configure `board_config.yaml`
Open `python_validation/board_config.yaml` and set your port and disable mock mode:
```yaml
serial:
  port: "/dev/tty.usbserial-10"   # Update with your port path
  baudrate: 115200
  timeout: 1.0
  mock_mode: false                # Set to false for physical testing
```

### Step 3: Run the Regression Suite
In your terminal, execute:
```bash
python3 python_validation/run_regression.py
```
This runs all 7 test cases and outputs coverage results.

---

## 4. Troubleshooting and FAQ

### Q1: Vivado fails to program: "Failed to open hardware target"
* **Check Power**: Ensure the board LEDs are lit. Verify that the power selector slide switch (SW2) is toggled to the correct power source (e.g., USB power).
* **Driver Issue**: If on Windows, ensure the FTDI JTAG driver is installed. If on Linux/macOS, ensure your JTAG programmer has permissions.
* **Disconnect JTAG Console**: Ensure no other instance of Vivado (like Hardware Manager) has locked the JTAG cable connection. Close any other open connections.

### Q2: Python outputs: "SerialException: Permission denied"
* **macOS/Linux Port Permissions**: The system requires write permissions to access the serial character device. Run this command to grant read/write access:
  ```bash
  sudo chmod 666 /dev/tty.usbserial-xxx   # macOS
  sudo chmod 666 /dev/ttyUSB0             # Linux
  ```
* **Port Lock**: Make sure you have closed any open serial terminal clients (like PuTTY, TeraTerm, Screen, or Arduino Serial Monitor) that are reading from the same port. Only one program can open the serial port at a time.

### Q3: All tests fail with: "TimeoutError: UART timed out waiting for response"
* **Check Baud Rate**: Confirm the baud rate is set to `115200` in both `board_config.yaml` and your top-level Verilog code.
* **Wrong COM Port**: Verify that you didn't select the JTAG channel instead of the UART channel of the FT2232H bridge. If two serial ports show up, try switching to the other port address in `board_config.yaml`.
* **Reset the Board**: Press the board reset button (`pb[4]` / center button) to reset the FPGA's internal logic, then try running the script again.
