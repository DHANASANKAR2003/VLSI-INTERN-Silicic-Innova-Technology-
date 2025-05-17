# I2C Master FSM in Verilog

## 🧠 Project Overview

This project implements a Finite State Machine (FSM)-based I2C Master using Verilog HDL. The FSM handles standard I2C protocol operations including:
- Start condition
- Slave addressing
- Read/Write bit transmission
- Acknowledgment (ACK) detection
- Data transmission
- Stop condition

It is designed to work in a simulated environment, using a Verilog testbench with realistic timing and slave behavior.

---

## 🚀 Features

- Implements a standard I2C Master protocol
- Supports 7-bit addressing
- Simulates both write operation and acknowledgment from slave
- Testbench includes:
  - Clock and reset logic
  - Slave simulation (ACK response)
  - State monitoring with human-readable names

---

## 📁 File Structure
```
├── i2c_master_fsm.v # I2C Master FSM module
├── tb_i2c_master_fsm.v # Testbench for the FSM
├── i2c_master.vcd # Waveform dump (generated after simulation)
├── state_diagram.png # [Optional] FSM state diagram image
├── waveform.png # [Optional] Simulation waveform image
└── README.md # This file
```

---

## 📊 FSM State Diagram

![State Diagram](state_diagram.png)

---

## 🌊 Sample Waveform

This waveform demonstrates a successful I2C write operation:
- Start condition
- 7-bit slave address and R/W bit
- ACK reception
- 8-bit data transmission
- Final ACK and stop condition

![Waveform Output](waveform.png)

---

## 🧪 Running the Simulation

### 🔧 Requirements

- [Icarus Verilog](http://iverilog.icarus.com/)
- GTKWave (for waveform viewing)

### ▶️ Commands

```bash
# Compile
iverilog -o i2c_master i2c_master_fsm.v tb_i2c_master_fsm.v

# Run
vvp i2c_master

# View waveform
gtkwave i2c_master.vcd
