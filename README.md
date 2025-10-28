# 🧠 VLSI Design & Verification Repository

![Verilog](https://img.shields.io/badge/HDL-Verilog-blue)
![SystemVerilog](https://img.shields.io/badge/HDL-SystemVerilog-orange)
![UVM](https://img.shields.io/badge/Verification-UVM-green)
![FPGA](https://img.shields.io/badge/Hardware-FPGA-yellow)
![Vivado](https://img.shields.io/badge/Tool-Xilinx%20Vivado-red)
![GTKWave](https://img.shields.io/badge/Tool-GTKWave-purple)
![Icarus](https://img.shields.io/badge/Simulator-Icarus%20Verilog-brightgreen)

---

## 🚀 Overview

Welcome to my **VLSI Design & Verification** collection —  
a showcase of my complete journey through **Verilog**, **SystemVerilog**, and **UVM**, including **RTL design**, **verification**, and **FPGA implementation**.

This repository includes everything from **basic circuits** to **industry-grade UVM testbenches**, organized for learning, simulation, and practical hardware design.

---

## 📁 Repository Structure


---

## ⚙️ Combinational Logic Circuits

> Designs that generate outputs purely from current inputs.

### 🧮 Included Designs
- Half Adder / Full Adder  
- Subtractor (Half, Full)  
- Multiplexer / Demultiplexer (2:1, 4:1, 8:1)  
- Encoder / Decoder (3:8, 4:2 priority encoder)  
- Comparator (2-bit, 4-bit)  
- Basic Logic Gates  

🧠 **Key Concepts:** Boolean equations, gate-level modeling, and combinational optimization.  
📈 **Use Case:** Arithmetic Units and Data Routing Circuits.

---

## 🔄 Sequential Logic Circuits

> Designs that depend on both **current input** and **previous state** (clock-driven).

### ⏱ Designs Implemented
- **Flip-Flops** — SR, D, JK, T, Master-Slave SR  
- **Counters** — Up, Down, Mod-N, Ring, Johnson  
- **Shift Registers** — SISO, SIPO, PISO, PIPO  
- **Finite State Machines (FSM)** — Moore & Mealy Models  
- **Sequence Detectors** — Detect 101, 1101, 1001 patterns  

🧠 **Key Concepts:** Clocking, edge-triggered design, timing control.  
📈 **Use Case:** Control systems, timing units, digital controllers.

---

## 🚀 Verilog Mini Projects

> Real-world digital systems combining combinational and sequential logic.

### 🧩 Projects List
- 🛰 **UART Transmitter & Receiver**  
- 🧠 **Sobel Edge Detection (with Python visualization)**  
- 🗳 **Voting Machine using FSM**  
- 🔗 **I²C Master–Slave Communication**  
- 💾 **8-bit SRAM Memory Controller**  
- 🧮 **ALU Design with Multiple Operations**  
- ⚡ **Traffic Light Controller**  
- 💧 **Fertilizer Automation using Relay Control**  
- 🧍‍♂️ **Drowsiness Detection System (FPGA + Camera Integration)**  

🧠 **Highlights:**  
- Integrated image processing with Verilog  
- 46+ Filter operations implemented  
- Real-time FPGA synthesis using **Vivado**

---

## 🧩 SystemVerilog Designs

> High-level design and verification modeling using SystemVerilog.

### 🧱 Topics Covered
- Data Types, Operators, and Procedural Blocks  
- Interfaces and Modports  
- Structures, Enums, and Dynamic Arrays  
- Covergroups, Assertions, and Constraints  
- Object-Oriented Programming Concepts  
- Constrained Random Verification (CRV)  
- Functional Coverage & Assertions (SVA)

### ⚡ Designs & Testbenches
- **D Flip-Flop using `always_ff`**  
- **4-bit Counter with Interface**  
- **FIFO Design & Verification**  
- **ALU Verification**  
- **FSM Verification using Assertions**  
- **Scoreboard & Coverage Implementation**

🧠 **Key Concepts:** Abstraction, modularity, and testbench automation.  
📈 **Use Case:** Verification of complex RTL blocks.

---

## 🧪 UVM (Universal Verification Methodology)

> Industry-standard verification framework built on SystemVerilog OOP concepts.

### 🧱 Components Implemented
| Component | Description |
|------------|-------------|
| **Sequence Item** | Transaction data model |
| **Sequencer** | Controls transaction flow |
| **Driver** | Drives DUT interface |
| **Monitor** | Observes DUT signals |
| **Agent** | Combines driver & monitor |
| **Environment** | Integrates all components |
| **Test** | Configures and runs the environment |

### 🧩 Example UVM Projects
- ✅ **Half Adder / D Flip-Flop Verification**  
- ✅ **UART Protocol Verification**  
- ✅ **I²C Master-Slave Verification**  
- ✅ **FSM Verification Example**  
- ✅ **FIFO Verification with Scoreboard**

🧠 **Concepts Applied:**  
Factory registration, configuration database, sequences, transactions, coverage, and reporting mechanisms.

---

## 🛠 Tools & Technologies

| Tool | Purpose |
|------|----------|
| **Icarus Verilog** | Simulation of Verilog/SystemVerilog |
| **GTKWave** | Waveform analysis |
| **Vivado** | FPGA Synthesis and Implementation |
| **Python** | Image data visualization (Sobel Filter outputs) |
| **QuestaSim / Synopsys VCS** | UVM testbench simulation |

---

## 🎨 Design Showcase

### 🧠 Image Processing (Sobel Edge Detection)
- Implemented **3×3 Sobel Operator** with line buffers  
- 46 filter operations including brightness, inversion, thresholding  
- Simulated with Icarus and visualized using Python  

### ⚡ FPGA Real-Time Implementation
- **Artix-7** FPGA integration  
- **OV5640 Camera → SDRAM → VGA Output Pipeline**  
- Fully synthesized using **Vivado**  

### 💧 Fertilizer Automation
- Controlled **3 solenoid valves** and **1 water pump** using **4-channel relay**  
- Real-time hardware prototype developed on **12V power system**

---

## 📚 Learning Milestones

- ✅ Mastered **Verilog RTL Design** and **FPGA Implementation**  
- ✅ Completed **SystemVerilog Functional Verification**  
- ✅ Built **UVM Testbench Environments**  
- ✅ Developed **real-time FPGA-based Image Processing System**  
- ✅ Created 100+ simulation test cases and 46 filter operations  

---

## 👨‍💻 Author

**DHANASANKAR K**  
🎓 Electronics & Communication Engineering  
💼 FPGA | Digital Design | SystemVerilog | UVM | Image Processing  

🔗 **GitHub:** [Dhanasankar2003](https://github.com/DHANASANKAR2003)  
🔗 **LinkedIn:** [linkedin.com/in/dhanasankar-k-23b196291](https://www.linkedin.com/in/dhanasankar-k-23b196291)

---

## 🌟 Acknowledgment

This repository compiles all of my **VLSI design and verification work**, from academic projects to professional internship experiences at  
**Silicic Innova Technology** and **Silicon Craft VLSI Training & Research Institute**.

> “Design with precision, verify with perfection.”
