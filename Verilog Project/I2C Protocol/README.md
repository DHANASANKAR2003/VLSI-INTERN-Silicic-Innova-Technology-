# 🧠 Verilog I²C Master-Slave Protocol

## 📌 Introduction

This project demonstrates a complete Verilog-based implementation of the I²C (Inter-Integrated Circuit) protocol. It includes:
- A fully functional I²C Master controller with FSM
- Five independent I²C Slave controllers (with unique addresses)
- Bit-level signal handling of SDA/SCL
- Read and Write operations

Simulated and tested using Icarus Verilog and GTKWave.


---

## 📁 Project Structure

### 📦 i2c-verilog
- i2c_controller.v # I²C Master Module
- i2c_slave_controller1.sv # Slave 1
- i2c_slave_controller2.sv # Slave 2
- i2c_slave_controller3.sv # Slave 3
- i2c_slave_controller4.sv # Slave 4
- i2c_slave_controller5.sv # Slave 5
- i2c_controller_tb.v # Testbench

---
## 📌 Features

- I²C Master with clock generation (SCL)
- Start/Stop condition generation
- Read/Write mode support
- ACK/NACK handling
- Up to 5 slave device addressing
- Full behavioral testbench with display outputs
- Synthesizable Verilog modules

---

## 🔄 Finite State Machine (FSM)

# 🧠 I²C Master Controller FSM (Finite State Machine)

This section explains the internal **FSM design** of the `i2c_controller` module. It governs I²C bit-level protocol including **Start/Stop conditions**, **Address phase**, **Data transfer**, and **ACK management**.

---

## 🧭 Master FSM States

| State Name    | Value | Description                                                                 |
|---------------|-------|-----------------------------------------------------------------------------|
| `IDLE`        | 0     | Waits for enable signal to initiate communication                           |
| `START`       | 1     | Generates the START condition (SDA goes low while SCL is high)              |
| `ADDRESS`     | 2     | Sends 7-bit slave address + R/W bit to the bus                              |
| `READ_ACK`    | 3     | Waits for ACK bit from slave                                                |
| `WRITE_DATA`  | 4     | Sends 8-bit data to slave                                                   |
| `WRITE_ACK`   | 5     | Receives ACK from slave after writing data                                  |
| `READ_DATA`   | 6     | Receives 8-bit data from slave                                              |
| `READ_ACK2`   | 7     | Sends ACK to slave after reading data                                       |
| `STOP`        | 8     | Generates the STOP condition (SDA goes high while SCL is high)              |

---

## 📈 Master FSM Flow Diagram

```text
                 +-------+
          +----->| IDLE  |<-----------+
          |      +-------+            |
     enable=1          |              |
          |            v              |
     +----------->+-----------+       |
     |            |  START    |       |
     |            +-----------+       |
     |                   |            |
     |                   v            |
     |            +-----------+       |
     |            | ADDRESS   |       |
     |            +-----------+       |
     |                   |            |
     |                   v            |
     |            +-----------+       |
     |            | READ_ACK  |       |
     |            +-----------+       |
     |               |        |       |
     |         R/W=0 |        | R/W=1 |
     |               v        v       |
     |        +-----------+  +------------+
     |        |WRITE_DATA|  | READ_DATA  |
     |        +-----------+  +------------+
     |               |              |
     |               v              v
     |        +-----------+  +-------------+
     |        |WRITE_ACK |  |  READ_ACK2   |
     |        +-----------+  +-------------+
     |               |              |
     +---------------+--------------+
                     |
                     v
                 +--------+
                 | STOP   |
                 +--------+
                     |
                     v
                 +--------+
                 | IDLE   |
                 +--------+

```
# 🧠 Verilog I²C Slave Controllers FSM

This section documents the internal **FSM (Finite State Machine)** structure of all five `i2c_slave_controller` modules used in the I²C Master-Slave Verilog project.

Each slave behaves identically in terms of control logic, with a unique 7-bit address. They handle address detection, acknowledgment (ACK), and read/write operations through state transitions triggered by SDA/SCL changes.

---

## 📜 Common Slave FSM States

| State Name   | Value | Description                                                                 |
|--------------|-------|-----------------------------------------------------------------------------|
| `READ_ADDR`  | 0     | Captures the 8-bit address + R/W bit from the master                        |
| `SEND_ACK`   | 1     | Sends ACK if address matches                                                |
| `READ_DATA`  | 2     | Receives 8-bit data from master during write operation                      |
| `WRITE_DATA` | 3     | Sends 8-bit data to master during read operation                            |
| `SEND_ACK2`  | 4     | Sends ACK after data is received                                            |

---

## 📈 FSM State Diagram

```text
     +-----------+
     | READ_ADDR |<-------------------------+
     +-----------+                          |
           | Address Captured               |
           v                                |
     +-----------+    Match?      No -------+
     | SEND_ACK  |---------------> STOP
     +-----------+
           |
     +----------------+
     | R/W bit = 0 ?  |--> Yes --> READ_DATA --> SEND_ACK2 --> back to READ_ADDR
     |                |
     |                |--> No  --> WRITE_DATA --> back to READ_ADDR
     +----------------+

```

## 🛠️ Simulation Instructions

### 🔧 Using Icarus Verilog & GTKWave

1. **Compile:**
   ```bash
   iverilog -o i2c_sim i2c_controller_tb.v i2c_controller.v i2c_slave_controller1.sv i2c_slave_controller2.sv i2c_slave_controller3.sv i2c_slave_controller4.sv i2c_slave_controller5.sv


---

###  Add Output Waveform Image
<img width="1356" alt="Screenshot 2025-07-01 at 10 52 55 AM" src="https://github.com/user-attachments/assets/65f6e49a-fb6d-44aa-af54-543e4d38cbe3" />

## 📊 Output Waveform

<img width="1353" alt="Screenshot 2025-07-01 at 10 53 15 AM" src="https://github.com/user-attachments/assets/1f7fbef1-af32-42d4-ad6b-f9ad2b414d47" />

## 🙏 Acknowledgements

- Developed by: **Dhanasankar K**
- Guided by:  **Swami, Ph.D, iFellow** (Silicon Craft VLSI)

