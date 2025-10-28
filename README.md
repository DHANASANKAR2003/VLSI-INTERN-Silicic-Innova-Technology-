# 🧠 VLSI Design & Verification Repository

<p align="center">
  <a href="https://dhanasankar2003.github.io/dhanasankar.github.io/">
    <img src="https://img.shields.io/badge/🌐_My%20Portfolio-Visit%20Now-blue?style=for-the-badge" />
  </a>
  <br><br>

  <a href="https://github.com/DHANASANKAR2003/VLSI-INTERN-Silicic-Innova-Technology-/tree/main/Assignments">
    <img src="https://img.shields.io/badge/📘_Verilog%20Assignments-Explore-blue?style=for-the-badge" />
  </a>

  <a href="https://github.com/DHANASANKAR2003/VLSI-INTERN-Silicic-Innova-Technology-/tree/main/COMBINATIONAL">
    <img src="https://img.shields.io/badge/⚙️_Combinational%20Circuits-Verilog%20Code-orange?style=for-the-badge" />
  </a>

  <a href="https://github.com/DHANASANKAR2003/VLSI-INTERN-Silicic-Innova-Technology-/tree/main/System%20Verilog">
    <img src="https://img.shields.io/badge/💡_SystemVerilog%20Designs-Code-yellow?style=for-the-badge" />
  </a>

  <a href="https://github.com/DHANASANKAR2003/VLSI-INTERN-Silicic-Innova-Technology-/tree/main/System%20Verilog%20Practice">
    <img src="https://img.shields.io/badge/🧩_SystemVerilog%20Practice-Examples-green?style=for-the-badge" />
  </a>

  <a href="https://github.com/DHANASANKAR2003/VLSI-INTERN-Silicic-Innova-Technology-/tree/main/Functional%20Verification%20Using%20System%20Verilog">
    <img src="https://img.shields.io/badge/🔬_Functional%20Verification-UVM%20Based-red?style=for-the-badge" />
  </a>

  <a href="https://github.com/DHANASANKAR2003/VLSI-INTERN-Silicic-Innova-Technology-/tree/main/HDL_Bits">
    <img src="https://img.shields.io/badge/💻_HDLBits-Practice%20Problems-purple?style=for-the-badge" />
  </a>

  <a href="https://github.com/DHANASANKAR2003/VLSI-INTERN-Silicic-Innova-Technology-/tree/main/Verilog%20Project">
    <img src="https://img.shields.io/badge/🚀_Verilog%20Projects-Real%20Time%20Designs-brightgreen?style=for-the-badge" />
  </a>
</p>


---

## 🚀 Overview

Welcome to my **VLSI Design & Verification** collection —  
a showcase of my journey through **Verilog**, **SystemVerilog**, and **UVM**, including **RTL design**, **functional verification**, and **FPGA hardware implementation**.

This repository demonstrates **academic learning + professional-level project execution** — from **logic design** to **FPGA-based real-time systems**.

---

## 📁 Repository Structure

| Category | Description |
|-----------|-------------|
| 🧮 **Combinational Circuits** | Basic logic design and gate-level modeling |
| ⏱ **Sequential Circuits** | Clock-based and FSM-driven designs |
| 💡 **Mini Projects** | Applied Verilog-based hardware systems |
| ⚙️ **SystemVerilog Designs** | Modern verification and OOP-based modeling |
| 🧪 **UVM Environments** | Industry-standard verification projects |
| 🧰 **Tools & Utilities** | Simulation, debugging, and waveform analysis |

---

## ⚙️ Combinational Logic Circuits

> Designs that produce outputs purely based on current inputs — no memory.

### 🧮 Implemented Designs
- Half Adder / Full Adder  
- Subtractor (Half, Full)  
- Multiplexer / Demultiplexer (2:1, 4:1, 8:1)  
- Encoder / Decoder (3:8, 4:2 Priority Encoder)  
- Comparator (2-bit, 4-bit)  
- Logic Gate Implementations (AND, OR, XOR, XNOR)

🧠 **Concepts:** Boolean simplification, gate-level & dataflow modeling  
📈 **Applications:** ALUs, data routing, signal selection systems

---

## 🔄 Sequential Logic Circuits

> Circuits that depend on both **current inputs** and **previous states** (clock-controlled).

### ⏱ Implemented Modules
- Flip-Flops: SR, D, JK, T, Master–Slave  
- Counters: Up, Down, Mod-N, Ring, Johnson  
- Shift Registers: SISO, SIPO, PISO, PIPO  
- FSM Designs: Moore and Mealy Models  
- Sequence Detectors (e.g., 101, 1101, 1001 patterns)

🧠 **Concepts:** Clock edge triggering, timing control, state transitions  
📈 **Applications:** Traffic lights, control units, sequence recognition

---

## 🚀 Verilog Mini Projects

> Real-world digital designs combining combinational and sequential logic.

### 🔧 Project Highlights
- 🛰 **UART Transmitter & Receiver**
  - Fully functional serial communication  
  - Includes parity check & baud rate configuration  

- 💬 **I²C Master–Slave Communication**
  - Multi-slave simulation with address decoding  
  - SDA/SCL bit-level timing management  

- 💾 **8-bit SRAM Memory Controller**
  - Address decoding, read/write enable logic  
  - Supports burst mode & error handling  

- ⚡ **Traffic Light Controller**
  - FSM-based real-time control logic  
  - Includes timer and pedestrian modes  

- 💧 **Fertilizer Automation**
  - Controlled **3 solenoid valves** & **1 water pump** via 4-channel relay  
  - 12V DC system using timing & sequencing logic  

- 🧠 **Sobel Edge Detection**
  - 3×3 convolution using line buffers  
  - Supports 46 filters (brightness, threshold, invert, etc.)  
  - Python visualization for processed outputs  

- 🧍‍♂️ **Driver Drowsiness Detection**
  - Integrated with camera & motor control system  
  - Edge detection → feature extraction → motor cutoff logic  

---

## 🧩 SystemVerilog Designs

> Modern HDL for modeling, simulation, and verification.

### 🧱 Covered Topics
- Data Types, Operators, Procedural Blocks  
- Interfaces & Modports  
- Dynamic Arrays, Structures, Enums  
- Assertions & Covergroups  
- Constrained Random Verification  
- Object-Oriented Concepts (class, inheritance, polymorphism)

### 🧠 Example Designs
- D Flip-Flop (`always_ff` usage)  
- 4-bit Counter with Interface  
- FIFO Design and Verification  
- ALU Verification Environment  
- FSM Verification using SVA  
- Scoreboard and Functional Coverage

🧠 **Concepts:** Reusability, abstraction, and constraint randomization  
📈 **Applications:** Industrial verification flows, modular testbenches

---

## 🧪 UVM (Universal Verification Methodology)

> A powerful object-oriented verification framework built on SystemVerilog.

### 🧩 Implemented Components
| Component | Description |
|------------|-------------|
| **Sequence Item** | Defines transaction data structure |
| **Sequencer** | Controls stimulus flow |
| **Driver** | Drives DUT inputs |
| **Monitor** | Observes and collects DUT signals |
| **Agent** | Combines Driver + Monitor |
| **Environment** | Integrates multiple agents |
| **Test Class** | Configures and runs UVM environment |

### ⚡ UVM Projects
- Half Adder & D Flip-Flop Verification  
- UART Protocol Verification  
- I²C Communication Verification  
- FSM & Counter Verification  
- FIFO Verification with Scoreboard  

🧠 **Concepts:** Factory registration, configuration DB, coverage, reporting  
📈 **Applications:** Reusable verification architectures

---

## 🧠 Advanced Design Highlights

### 🧩 Image Processing (Sobel + Filters)
- Real-time **Sobel edge detection** using 3×3 matrix  
- Supports **46 filters** (blur, sharpen, threshold, invert, etc.)  
- Python visualization for grayscale outputs  
- Synthesized on **Artix-7 FPGA**

### 💧 Fertilizer Automation
- Real hardware integration: **Solenoid valves**, **water pump**, **relays**  
- Controlled via Verilog logic & timing-based sequencing  
- 12V power design, 1A current regulation  

### ⚙️ FPGA Integration
- Camera Input (OV5640) → SDRAM → VGA Output Pipeline  
- Designed and implemented in **Vivado**  
- Real-time video processing verified on FPGA  

---

## 🧰 Tools & Technologies

| Tool | Function |
|------|-----------|
| **Icarus Verilog** | Simulation engine for Verilog/SystemVerilog |
| **GTKWave** | Waveform viewing and debugging |
| **Vivado Design Suite** | FPGA synthesis & implementation |
| **Python (Matplotlib/Numpy)** | Image visualization for Sobel filters |
| **QuestaSim / VCS** | UVM testbench simulation |

---

## 📚 Learning Milestones

✅ Verilog RTL Design & FPGA Implementation  
✅ SystemVerilog Functional Verification  
✅ UVM Environment Development  
✅ Real-Time Image Processing System  
✅ 100+ Test Cases, 46 Filter Operations  

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
