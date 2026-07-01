# I2C Master-Slave Communication in Verilog

## 🧠 Project Overview

This project implements a Finite State Machine (FSM)-based I2C Master and slave using Verilog. The FSM handles standard I2C protocol operations including:
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

<img width="679" alt="Screenshot 2025-05-17 at 4 22 22 PM" src="https://github.com/user-attachments/assets/e91b5806-dcb7-4273-8100-433c26a06473" />

---

## 🌊 Sample Waveform

This waveform demonstrates a successful I2C write operation:
- Start condition
- 7-bit slave address and R/W bit
- ACK reception
- 8-bit data transmission
- Final ACK and stop condition

<img width="1414" alt="Screenshot 2025-05-17 at 4 20 36 PM" src="https://github.com/user-attachments/assets/9d518bd1-c1fe-4b73-9d4d-1afc4ccd4b86" />

---
## 🌊 Sample Waveform for master and slave communication
<img width="1415" alt="Screenshot 2025-05-17 at 4 34 50 PM" src="https://github.com/user-attachments/assets/a6ea6d07-0cf5-4a97-953f-a1349855fe80" />

---
## 🌊 Output for master 
```
VCD info: dumpfile i2c_master.vcd opened for output.
==== Initializing Test ====
Time=0 | State=      IDLE | SDA_out=1 | SDA_in=1 | SCL=1
  Deasserting reset
  Initiating I2C transaction
Time=210000 | State=_CONDITION | SDA_out=1 | SDA_in=1 | SCL=1
Time=230000 | State=VE_ADDRESS | SDA_out=0 | SDA_in=0 | SCL=1
Time=250000 | State=VE_ADDRESS | SDA_out=1 | SDA_in=1 | SCL=0
Time=270000 | State=VE_ADDRESS | SDA_out=0 | SDA_in=0 | SCL=1
Time=290000 | State=VE_ADDRESS | SDA_out=0 | SDA_in=0 | SCL=0
Time=310000 | State=VE_ADDRESS | SDA_out=1 | SDA_in=1 | SCL=1
Time=330000 | State=VE_ADDRESS | SDA_out=1 | SDA_in=1 | SCL=0
Time=350000 | State=VE_ADDRESS | SDA_out=0 | SDA_in=0 | SCL=1
Time=370000 | State=VE_ADDRESS | SDA_out=0 | SDA_in=0 | SCL=0
Time=390000 | State=VE_ADDRESS | SDA_out=0 | SDA_in=0 | SCL=1
Time=410000 | State=VE_ADDRESS | SDA_out=0 | SDA_in=0 | SCL=0
Time=430000 | State=VE_ADDRESS | SDA_out=0 | SDA_in=0 | SCL=1
Time=450000 | State=VE_ADDRESS | SDA_out=0 | SDA_in=0 | SCL=0
Time=470000 | State=VE_ADDRESS | SDA_out=0 | SDA_in=0 | SCL=1
Time=490000 | State=    RW_BIT | SDA_out=0 | SDA_in=0 | SCL=0
Time=510000 | State=    RW_BIT | SDA_out=0 | SDA_in=0 | SCL=1
 Entered ACK_BIT state. Simulating ACK from slave...
Time=530000 | State=   ACK_BIT | SDA_out=0 | SDA_in=0 | SCL=0
Time=550000 | State=   ACK_BIT | SDA_out=0 | SDA_in=0 | SCL=1
Time=570000 | State=      DATA | SDA_out=0 | SDA_in=0 | SCL=0
Time=590000 | State=      DATA | SDA_out=1 | SDA_in=1 | SCL=1
Time=610000 | State=      DATA | SDA_out=1 | SDA_in=1 | SCL=0
Time=630000 | State=      DATA | SDA_out=0 | SDA_in=0 | SCL=1
Time=650000 | State=      DATA | SDA_out=0 | SDA_in=0 | SCL=0
Time=670000 | State=      DATA | SDA_out=1 | SDA_in=1 | SCL=1
Time=690000 | State=      DATA | SDA_out=1 | SDA_in=1 | SCL=0
Time=710000 | State=      DATA | SDA_out=0 | SDA_in=0 | SCL=1
Time=730000 | State=      DATA | SDA_out=0 | SDA_in=0 | SCL=0
Time=750000 | State=      DATA | SDA_out=1 | SDA_in=1 | SCL=1
Time=770000 | State=      DATA | SDA_out=1 | SDA_in=1 | SCL=0
Time=790000 | State=      DATA | SDA_out=0 | SDA_in=0 | SCL=1
Time=810000 | State=      DATA | SDA_out=0 | SDA_in=0 | SCL=0
Time=830000 | State=      DATA | SDA_out=1 | SDA_in=1 | SCL=1
Time=850000 | State=      DATA | SDA_out=1 | SDA_in=1 | SCL=0
Time=870000 | State=      DATA | SDA_out=0 | SDA_in=0 | SCL=1
 Entered ACK_1_BIT state. Simulating ACK from slave...
Time=890000 | State= ACK_1_BIT | SDA_out=0 | SDA_in=0 | SCL=0
Time=910000 | State= ACK_1_BIT | SDA_out=0 | SDA_in=0 | SCL=1
Time=930000 | State=_CONDITION | SDA_out=0 | SDA_in=0 | SCL=0
 FSM returned to IDLE. I2C operation complete.
Time=950000 | State=      IDLE | SDA_out=1 | SDA_in=1 | SCL=1
Time=970000 | State=_CONDITION | SDA_out=1 | SDA_in=1 | SCL=1
Time=990000 | State=VE_ADDRESS | SDA_out=0 | SDA_in=0 | SCL=1
Time=1010000 | State=VE_ADDRESS | SDA_out=1 | SDA_in=1 | SCL=0
Time=1030000 | State=VE_ADDRESS | SDA_out=0 | SDA_in=0 | SCL=1
 I2C FSM Test Completed Successfully.
testbench.sv:93: $finish called at 1050000 (1ps)
Time=1050000 | State=VE_ADDRESS | SDA_out=0 | SDA_in=0 | SCL=0
Finding VCD file...
./i2c_master.vcd
```
---
## 🌊 Output for master and slave
```
design.sv:1: ...: The inherited timescale is here.
VCD info: dumpfile i2c_master_slave.vcd opened for output.
I2C Master-Slave Write Test Complete.
testbench.sv:48: $finish called at 2200000 (1ps)
```
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
