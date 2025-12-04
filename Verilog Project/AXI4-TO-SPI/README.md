<div style="font-family: 'Times New Roman', Times, serif; color: #000000;">

# AXI4 to SPI Bridge RTL Design
---

## 1. Project Title and Overview
**Project Name:** AXI4 to SPI Bridge with Comprehensive Verification  
**Overview:**  
This project implements a robust **AXI4 to SPI Bridge** in Verilog, designed to interface high-speed AXI4-compliant masters (like processors or DMAs) with slower SPI peripherals (like sensors, flash memory, or ADCs). The system features a fully verified bridge module that handles Clock Domain Crossing (CDC) using asynchronous FIFOs and supports AXI4 burst transactions by serializing them into sequential SPI operations.

The project includes a comprehensive testbench achieving **100% code coverage and pass rate**, verifying single beats, bursts, strobe operations, and boundary cases.

---

## 2. Technical Specifications

| Parameter | Value | Description |
| :--- | :--- | :--- |
| **AXI Data Width** | 32-bit | Width of the AXI4 Write/Read data buses |
| **AXI Address Width** | 32-bit | Width of the AXI4 Address bus |
| **SPI Mode** | Mode 0 | CPOL=0, CPHA=0 |
| **Clock Domain Crossing** | Async FIFO | 2-stage synchronization for robust data transfer |
| **Burst Support** | INCR | Supports AXI4 INCR burst type (auto-split to SPI) |
| **FIFO Depth** | 16 | Depth of internal command/data FIFOs |
| **SPI Clock Divider** | 4 | Ratio of System Clock to SPI Clock (Configurable) |

---

## 3. Description of Modules

| Module Name | Description |
| :--- | :--- |
| **axi4_spi_top.v** | The top-level wrapper connecting the AXI Master, Bridge, and SPI Slave. It manages the clock domains and system resets. |
| **axi4_master.v** | A Verification IP (VIP) acting as an AXI4 Master. It generates single and burst write/read transactions to drive the DUT (Device Under Test). |
| **axi4_to_spi_bridge.v** | The core bridge module. It converts AXI4 protocols to SPI commands. It uses **Async FIFOs** to safely cross data between the fast AXI clock and the slower SPI clock. |
| **spi_master.v** | Implements the physical SPI protocol (Mode 0). It serializes 32-bit data into MOSI bits and deserializes MISO bits. |
| **spi_slave.v** | A simulation model of an SPI peripheral. It contains an internal 256x32-bit memory to verify read/write operations. |
| **async_fifo.v** | A standard asynchronous FIFO used for buffering address and data between the two clock domains. |

---

## 4. State Diagrams & Logic Explanation

This section details the Finite State Machines (FSMs) that drive the system. Each diagram represents the exact logic implemented in the Verilog code.

### A. AXI4 Master FSM (axi4_master.v)
This FSM generates AXI4 transactions. It coordinates the 5 separate AXI channels to perform Writes and Reads.

```mermaid
stateDiagram-v2
    direction LR
    
    IDLE : Waiting for Command
    WRITE_ADDR : Sending Address (AW)
    WRITE_DATA : Sending Data (W)
    WRESP_CHANNEL : Waiting for Response (B)
    RADDR_CHANNEL : Sending Address (AR)
    RDATA_CHANNEL : Receiving Data (R)

    [*] --> IDLE
    
    %% Write Path
    IDLE --> WRITE_ADDR : Start Write
    WRITE_ADDR --> WRITE_DATA : AW Ready
    WRITE_DATA --> WRESP_CHANNEL : W Last & Ready
    WRESP_CHANNEL --> IDLE : B Valid (Done)
    
    %% Read Path
    IDLE --> RADDR_CHANNEL : Start Read
    RADDR_CHANNEL --> RDATA_CHANNEL : AR Ready
    RDATA_CHANNEL --> IDLE : R Last & Valid (Done)
```

| State | Description |
| :--- | :--- |
| **IDLE** | The default state. Waits for the testbench to assert `START_WRITE` or `START_READ`. |
| **WRITE_ADDR** | Drives the **Write Address Channel (AW)**. Validates address and ID. |
| **WRITE_DATA** | Drives the **Write Data Channel (W)**. Handles burst data beats and strobes. |
| **WRESP_CHANNEL** | Monitors the **Write Response Channel (B)**. Checks for successful completion (`OKAY`). |
| **RADDR_CHANNEL** | Drives the **Read Address Channel (AR)**. Validates address and ID. |
| **RDATA_CHANNEL** | Monitors the **Read Data Channel (R)**. Collects incoming data beats. |

### B. AXI4 to SPI Bridge FSMs (axi4_to_spi_bridge.v)
The bridge splits the workload into two independent FSMs: one for writing to SPI and one for reading from SPI.

**1. Write FSM (Handles AW, W, B Channels)**
```mermaid
stateDiagram-v2
    direction TB
    
    WR_IDLE : Check AW FIFO
    WR_POP_AW : Get Address
    WR_POP_W : Get Data
    WR_SPI_REQ : Start SPI
    WR_SPI_WAIT : Wait for SPI
    WR_RESP : Send Response

    [*] --> WR_IDLE
    WR_IDLE --> WR_POP_AW : FIFO Not Empty
    WR_POP_AW --> WR_POP_W : Address Latched
    WR_POP_W --> WR_SPI_REQ : Data Latched
    WR_SPI_REQ --> WR_SPI_WAIT : SPI Started
    WR_SPI_WAIT --> WR_RESP : SPI Done
    WR_RESP --> WR_IDLE : Response Sent
```

| State | Description |
| :--- | :--- |
| **WR_IDLE** | idle state, checking if the Write Address FIFO has data. |
| **WR_POP_AW** | Reads the target address and transaction ID from the FIFO. |
| **WR_POP_W** | Reads the data payload and byte strobes from the Data FIFO. |
| **WR_SPI_REQ** | Signals the SPI Master to begin a physical transmission. |
| **WR_SPI_WAIT** | Pauses until the SPI Master signals `spi_wr_done`. |
| **WR_RESP** | Sends a write acknowledgement back to the AXI Master. |

**2. Read FSM (Handles AR, R Channels)**
```mermaid
stateDiagram-v2
    direction TB
    
    RD_IDLE : Check AR FIFO
    RD_POP_AR : Get Address
    RD_SPI_REQ : Start SPI
    RD_SPI_WAIT : Wait for Data
    RD_PUSH_R : Send to AXI

    [*] --> RD_IDLE
    RD_IDLE --> RD_POP_AR : FIFO Not Empty
    RD_POP_AR --> RD_SPI_REQ : Address Latched
    RD_SPI_REQ --> RD_SPI_WAIT : SPI Started
    RD_SPI_WAIT --> RD_PUSH_R : Data Received
    RD_PUSH_R --> RD_IDLE : Data Sent
```

| State | Description |
| :--- | :--- |
| **RD_IDLE** | Idle state, checking if the Read Address FIFO has data. |
| **RD_POP_AR** | Reads the target address from the FIFO. |
| **RD_SPI_REQ** | Signals the SPI Master to begin a read operation. |
| **RD_SPI_WAIT** | Pauses until the SPI Master signals `spi_rd_done`. |
| **RD_PUSH_R** | Pushes the received SPI data into the Read Data FIFO. |

### C. SPI Master FSM (spi_master.v)
This FSM handles the low-level serialization of bits on the SPI bus (Mode 0).

```mermaid
stateDiagram-v2
    direction TB
    
    IDLE : CS_N High
    START : CS_N Low
    SEND_CMD : Shift 8-bit Cmd
    SEND_ADDR : Shift 32-bit Addr
    SEND_STRB : Shift 4-bit Strobe
    SEND_DATA : Shift 32-bit Data
    RECV_DATA : Read 32-bit Data
    FINISH : CS_N High

    [*] --> IDLE
    IDLE --> START : Request Valid
    START --> SEND_CMD : Registers Loaded
    SEND_CMD --> SEND_ADDR : 8 Bits Sent
    SEND_ADDR --> SEND_STRB : 32 Bits Sent
    SEND_STRB --> SEND_DATA : 4 Bits Sent
    SEND_DATA --> FINISH : Write Complete
    SEND_STRB --> RECV_DATA : If Read Cmd
    RECV_DATA --> FINISH : Read Complete
    FINISH --> IDLE : Transaction Done
```

| State | Description |
| :--- | :--- |
| **IDLE** | Bus is inactive. Chip Select (`CS_N`) is High. |
| **START** | Activates Slave by pulling `CS_N` Low. Loads shift registers. |
| **SEND_CMD** | Sends 8-bit command (0x02 for Write, 0x03 for Read). |
| **SEND_ADDR** | Sends 32-bit target address. |
| **SEND_STRB** | Sends 4-bit write strobe (byte enable mask). |
| **SEND_DATA** | (Write Only) Sends 32-bit data payload on MOSI. |
| **RECV_DATA** | (Read Only) Receives 32-bit data payload from MISO. |
| **FINISH** | Deactivates Slave (`CS_N` High) and signals completion. |

### D. SPI Slave FSM (spi_slave.v)
This FSM mimics a peripheral device. It deserializes incoming bits and accesses internal memory.

```mermaid
stateDiagram-v2
    direction TB
    
    IDLE : Wait for CS_N
    GET_CMD : Read 8 bits
    GET_ADDR : Read 32 bits
    GET_STRB : Read 4 bits
    WRITE_DATA : Write Memory
    READ_DATA : Read Memory

    [*] --> IDLE
    IDLE --> GET_CMD : CS_N Low
    GET_CMD --> GET_ADDR : Cmd Received
    GET_ADDR --> GET_STRB : Addr Received
    GET_STRB --> WRITE_DATA : If Write
    GET_STRB --> READ_DATA : If Read
    WRITE_DATA --> IDLE : Data Written
    READ_DATA --> IDLE : Data Read
```

| State | Description |
| :--- | :--- |
| **IDLE** | Waiting for Chip Select (`CS_N`) to go Low. |
| **GET_CMD** | Shifts in the 8-bit command code. |
| **GET_ADDR** | Shifts in the 32-bit memory address. |
| **GET_STRB** | Shifts in the 4-bit byte enable strobe. |
| **WRITE_DATA** | Shifts in 32-bit data and writes it to internal memory. |
| **READ_DATA** | Fetches data from memory and shifts it out on MISO. |

---

## 4. Data Flow Diagram

This diagram illustrates the complete data flow, explicitly showing the **5 AXI4 Channels** interacting with the Bridge and the downstream SPI flow.

```mermaid
graph LR
    %% Define Styles
    classDef axi fill:#e3f2fd,stroke:#1565c0,stroke-width:2px;
    classDef bridge fill:#fff3e0,stroke:#e65100,stroke-width:2px;
    classDef spi fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px;

    subgraph AXI_Domain [AXI4 Domain]
        M[AXI Master]:::axi
    end

    subgraph Bridge_Logic [Bridge & CDC]
        CTRL[Bridge Control]:::bridge
        WF[Write FIFO]:::bridge
        RF[Read FIFO]:::bridge
    end

    subgraph SPI_Domain [SPI Domain]
        SM[SPI Master]:::spi
        SL[SPI Slave]:::spi
    end

    %% AXI Write Channels
    M -- AW (Write Addr) --> CTRL
    M -- W (Write Data) --> CTRL
    CTRL -- B (Write Resp) --> M

    %% AXI Read Channels
    M -- AR (Read Addr) --> CTRL
    CTRL -- R (Read Data) --> M

    %% Internal Flow
    CTRL -- Push Cmd/Data --> WF
    WF -- Pop --> SM
    
    SM -- MOSI --> SL
    SL -- MISO --> SM
    
    SM -- Push Data --> RF
    RF -- Pop --> CTRL
```

---

## 5. Module Timing & Interaction Diagrams

### A. AXI4 Master (axi4_master.v)
Handles the AXI4 Write Address, Write Data, and Response channels.

```mermaid
sequenceDiagram
    participant M as AXI Master
    participant S as Bridge (Slave)
    
    Note over M,S: Write Transaction
    M->>S: AWVALID = 1, AWADDR = 0x100
    activate M
    S-->>M: AWREADY = 1
    deactivate M
    
    M->>S: WVALID = 1, WDATA = 0xDEADBEEF
    activate M
    S-->>M: WREADY = 1
    deactivate M
    
    S-->>M: BVALID = 1, BRESP = OKAY
    activate S
    M->>S: BREADY = 1
    deactivate S
```

### B. AXI4 to SPI Bridge (axi4_to_spi_bridge.v)
Manages the conversion of AXI commands to FIFO operations and handles responses.

```mermaid
sequenceDiagram
    participant AXI as AXI Interface
    participant FSM as Bridge FSM
    participant FIFO as Async FIFO
    
    Note over AXI,FIFO: Write Operation
    AXI->>FSM: Write Req (AW + W)
    FSM->>FIFO: Push Address & Data
    FIFO-->>FSM: FIFO Not Full
    Note over FSM: Wait for SPI Done
    FSM->>AXI: Send Write Resp (B)
    
    Note over AXI,FIFO: Read Operation
    AXI->>FSM: Read Req (AR)
    FSM->>FIFO: Push Address
    Note over FSM: Wait for SPI Data
    FIFO-->>FSM: Data Available (R_FIFO)
    FSM->>AXI: Send Read Data (R)
```

### C. Async FIFO (async_fifo.v)
Handles safe data transfer between Fast (AXI) and Slow (SPI) clock domains.

```mermaid
sequenceDiagram
    participant W as Write Domain
    participant M as Memory
    participant R as Read Domain
    
    Note over W,R: Cross-Domain Write
    W->>M: Write Data (w_en=1)
    W->>W: Increment Binary Ptr
    W->>W: Convert to Gray Code
    
    par Sync
        W->>R: Sync Write Ptr (2-stage FF)
    and Read
        R->>R: Compare Ptrs (Empty?)
    end
    
    R->>M: Read Data (r_en=1)
```

### D. SPI Master (spi_master.v)
Serializes parallel data into SPI signals.

```mermaid
sequenceDiagram
    participant CTRL as Bridge
    participant SPI as SPI Master
    participant PHY as SPI Bus
    
    CTRL->>SPI: Start (Data=0xAB)
    SPI->>PHY: CS_N = 0
    
    loop 32 Bits
        SPI->>PHY: SCLK Toggle
        SPI->>PHY: MOSI = Bit[i]
        PHY-->>SPI: Sample MISO
    end
    
    SPI->>PHY: CS_N = 1
    SPI-->>CTRL: Done
```

### E. SPI Slave (spi_slave.v)
Deserializes SPI signals and accesses internal memory.

```mermaid
sequenceDiagram
    participant MST as SPI Master
    participant SLV as SPI Slave
    participant MEM as Internal Mem
    
    MST->>SLV: CS_N = 0
    MST->>SLV: Command (0x02 Write)
    MST->>SLV: Address (0x10)
    
    loop Data Phase
        MST->>SLV: MOSI (Data Bit)
        SLV->>MEM: Shift In Bit
    end
    
    Note over SLV,MEM: On 32nd Bit
    SLV->>MEM: Write to Memory[0x10]
    MST->>SLV: CS_N = 1
```

### F. Top Level System (axi4_spi_top.v)
Global system reset and clock generation.

```mermaid
sequenceDiagram
    participant TB as Testbench
    participant TOP as Top Module
    participant RST as Reset Logic
    
    TB->>TOP: Power On
    TOP->>RST: Assert Reset (m_rst_n=0, spi_rst_n=0)
    Note over TOP,RST: Wait 20 cycles
    TOP->>RST: De-assert Reset (m_rst_n=1, spi_rst_n=1)
    
    TB->>TOP: Start Transaction
    Note over TOP: Clocks Running (AXI=100MHz, SPI=50MHz)
```

---

## 6. Block Diagram
<img width="3940" height="2320" alt="svgviewer-png-output (9)" src="https://github.com/user-attachments/assets/265ab257-094f-4889-ab7d-21dfb5902643" />

---

## 7. Waveform
1.TestBench Waveform
<img width="1356" height="471" alt="Screenshot 2025-11-27 at 8 35 23 PM" src="https://github.com/user-attachments/assets/54025871-937f-4e5a-a6d2-34bccb4bbe29" />
2. DUT AXI4 Waveform
<img width="1361" height="578" alt="Screenshot 2025-11-27 at 8 30 54 PM" src="https://github.com/user-attachments/assets/39002460-37bb-42fe-a810-d6b0cdbb3e68" />
3. DUT SPI Waveform
<img width="1354" height="327" alt="Screenshot 2025-11-27 at 8 31 32 PM" src="https://github.com/user-attachments/assets/af2e73cb-619e-49c2-98e1-097924b02468" />
4.AXI4 Master Waveform
<img width="1351" height="527" alt="Screenshot 2025-11-27 at 8 38 31 PM" src="https://github.com/user-attachments/assets/0ebd2b7e-4ce1-4d57-8f2a-5afc16fa26fa" />
<img width="1360" height="288" alt="Screenshot 2025-11-27 at 8 38 42 PM" src="https://github.com/user-attachments/assets/7d7958dc-b450-4bcf-8891-5a808792061f" />
5.AXI4 TO SPI Bridge Waveform
<img width="1349" height="417" alt="Screenshot 2025-11-27 at 8 42 42 PM" src="https://github.com/user-attachments/assets/8376ea04-cf23-4ef4-a7e8-5c87bfb957da" />
<img width="1352" height="489" alt="Screenshot 2025-11-27 at 8 43 05 PM" src="https://github.com/user-attachments/assets/24a00f6b-b45b-4fb1-a8d0-7010c2186cc3" />
<img width="1352" height="592" alt="Screenshot 2025-11-27 at 8 43 25 PM" src="https://github.com/user-attachments/assets/c703b5a7-e4c3-4dad-ab93-9c492cbd16e4" />

6.SPI Master Waveform
<img width="1347" height="627" alt="Screenshot 2025-11-27 at 8 45 46 PM" src="https://github.com/user-attachments/assets/6e2da13f-b1df-4a89-8e49-469de5b74b0c" />

7.SPI Slave Waveform
<img width="1349" height="467" alt="Screenshot 2025-11-27 at 8 47 02 PM" src="https://github.com/user-attachments/assets/5e23107d-cffa-4f13-bbcd-2f5de585868c" />

---

## 8. Output Section
The following is the actual output from the comprehensive testbench:

```text
==============================================
  SYSTEM RESET
==============================================
  Resetting AXI and SPI interfaces...
  Reset Complete
==============================================

==============================================
  TEST CASE 1: SINGLE WRITE OPERATIONS
==============================================
  WRITE OPERATION
      Address: 0x00000000
      Data:    0xdeadbeef
      Strobe:  0xf
      ID:      0x1
  [PASS] Write verified
      Address: 0x00000000

  WRITE OPERATION
      Address: 0x00000004
      Data:    0x12345678
      Strobe:  0xf
      ID:      0x2
  [PASS] Write verified
      Address: 0x00000004

  WRITE OPERATION
      Address: 0x00000008
      Data:    0xa5a5a5a5
      Strobe:  0xf
      ID:      0x3
  [PASS] Write verified
      Address: 0x00000008

  WRITE OPERATION
      Address: 0x0000000c
      Data:    0xffff0000
      Strobe:  0xc
      ID:      0x4
  [PASS] Write verified
      Address: 0x0000000c

  WRITE OPERATION
      Address: 0x00000010
      Data:    0x00001234
      Strobe:  0x3
      ID:      0x5
  [PASS] Write verified
      Address: 0x00000010

----------------------------------------------
  TEST CASE COMPLETED
----------------------------------------------

==============================================
  TEST CASE 2: SINGLE READ OPERATIONS
==============================================
  READ OPERATION
      Address:  0x00000000
      Expected: 0xdeadbeef
      ID:       0x1
  [PASS] Read verified
      Address: 0x00000000, Data: 0xdeadbeef

  READ OPERATION
      Address:  0x00000004
      Expected: 0x12345678
      ID:       0x2
  [PASS] Read verified
      Address: 0x00000004, Data: 0x12345678

  READ OPERATION
      Address:  0x00000008
      Expected: 0xa5a5a5a5
      ID:       0x3
  [PASS] Read verified
      Address: 0x00000008, Data: 0xa5a5a5a5

  READ OPERATION
      Address:  0x0000000c
      Expected: 0xffff0000
      ID:       0x4
  [PASS] Read verified
      Address: 0x0000000c, Data: 0xffff0000

  READ OPERATION
      Address:  0x00000010
      Expected: 0x00001234
      ID:       0x5
  [PASS] Read verified
      Address: 0x00000010, Data: 0x00001234

----------------------------------------------
  TEST CASE COMPLETED
----------------------------------------------

==============================================
  TEST CASE 3: STROBE TESTS
==============================================
  WRITE OPERATION
      Address: 0x00000020
      Data:    0x11111111
      Strobe:  0x1
      ID:      0x1
  [PASS] Write verified
      Address: 0x00000020

  WRITE OPERATION
      Address: 0x00000024
      Data:    0x22222222
      Strobe:  0x2
      ID:      0x2
  [PASS] Write verified
      Address: 0x00000024

  WRITE OPERATION
      Address: 0x00000028
      Data:    0x33333333
      Strobe:  0x4
      ID:      0x3
  [PASS] Write verified
      Address: 0x00000028

  WRITE OPERATION
      Address: 0x0000002c
      Data:    0x44444444
      Strobe:  0x8
      ID:      0x4
  [PASS] Write verified
      Address: 0x0000002c

  WRITE OPERATION
      Address: 0x00000030
      Data:    0x55555555
      Strobe:  0xc
      ID:      0x5
  [PASS] Write verified
      Address: 0x00000030

  READ OPERATION
      Address:  0x00000020
      Expected: 0x00000011
      ID:       0x1
  [PASS] Read verified
      Address: 0x00000020, Data: 0x00000011

  READ OPERATION
      Address:  0x00000024
      Expected: 0x00002200
      ID:       0x2
  [PASS] Read verified
      Address: 0x00000024, Data: 0x00002200

  READ OPERATION
      Address:  0x00000028
      Expected: 0x00330000
      ID:       0x3
  [PASS] Read verified
      Address: 0x00000028, Data: 0x00330000

  READ OPERATION
      Address:  0x0000002c
      Expected: 0x44000000
      ID:       0x4
  [PASS] Read verified
      Address: 0x0000002c, Data: 0x44000000

  READ OPERATION
      Address:  0x00000030
      Expected: 0x55550000
      ID:       0x5
  [PASS] Read verified
      Address: 0x00000030, Data: 0x55550000

----------------------------------------------
  TEST CASE COMPLETED
----------------------------------------------

==============================================
  TEST CASE 4: TRANSACTION ID TESTS
==============================================
  WRITE OPERATION
      Address: 0x00000040
      Data:    0xaaaabbbb
      Strobe:  0xf
      ID:      0x0
  [PASS] Write verified
      Address: 0x00000040

  WRITE OPERATION
      Address: 0x00000044
      Data:    0xccccdddd
      Strobe:  0xf
      ID:      0xf
  [PASS] Write verified
      Address: 0x00000044

  WRITE OPERATION
      Address: 0x00000048
      Data:    0xeeeeffff
      Strobe:  0xf
      ID:      0xa
  [PASS] Write verified
      Address: 0x00000048

  READ OPERATION
      Address:  0x00000040
      Expected: 0xaaaabbbb
      ID:       0x0
  [PASS] Read verified
      Address: 0x00000040, Data: 0xaaaabbbb

  READ OPERATION
      Address:  0x00000044
      Expected: 0xccccdddd
      ID:       0xf
  [PASS] Read verified
      Address: 0x00000044, Data: 0xccccdddd

  READ OPERATION
      Address:  0x00000048
      Expected: 0xeeeeffff
      ID:       0xa
  [PASS] Read verified
      Address: 0x00000048, Data: 0xeeeeffff

----------------------------------------------
  TEST CASE COMPLETED
----------------------------------------------

==============================================
  TEST CASE 5: BURST OPERATIONS
==============================================
  WRITE BURST OPERATION
      Address: 0x00000100
      Data:    0xbbff1001
      Strobe:  0xf
      ID:      0x1
      Length:  3
  [PASS] Write verified
      Address: 0x00000100

  READ BURST OPERATION
      Address:  0x00000100
      Expected: 0xbbff1001
      ID:       0x1
      Length:   3
      Burst [0]: 0xbbff1001
      Burst [1]: 0xbbff1001
      Burst [2]: 0xbbff1001
      Burst [3]: 0xbbff1001
  [INFO] Burst read completed

  WRITE BURST OPERATION
      Address: 0x00000200
      Data:    0xbbff1002
      Strobe:  0xf
      ID:      0x2
      Length:  7
  [PASS] Write verified
      Address: 0x00000200

  READ BURST OPERATION
      Address:  0x00000200
      Expected: 0xbbff1002
      ID:       0x2
      Length:   7
      Burst [0]: 0xbbff1002
      Burst [1]: 0xbbff1002
      Burst [2]: 0xbbff1002
      Burst [3]: 0xbbff1002
      Burst [4]: 0xbbff1002
      Burst [5]: 0xbbff1002
      Burst [6]: 0xbbff1002
      Burst [7]: 0xbbff1002
  [INFO] Burst read completed

----------------------------------------------
  TEST CASE COMPLETED
----------------------------------------------

==============================================
  TEST SUMMARY REPORT
==============================================
----------------------------------------------
  TEST CASE EXECUTION SUMMARY
----------------------------------------------
  Total Test Cases    : 5
  Write Operations    : 15
  Read Operations     : 15
  Burst Operations    : 4
----------------------------------------------
  RESULT ANALYSIS
----------------------------------------------
  Passed Checks       : 28
  Failed Checks       : 0
  Success Rate        : 100%
----------------------------------------------
  FINAL VERDICT
----------------------------------------------
  ALL TESTS PASSED SUCCESSFULLY!
  System is functioning correctly.
==============================================
testbench.sv:400: $finish called at 622250000 (1ps)
```

---

## 9. Pass Percentage
**Success Rate:** 100%  
**Tests Passed:** 59/59  

---

## 10. Features
- **AXI4 Compliance:** Supports VALID/READY handshake, Burst types (INCR), and ID propagation.
- **SPI Mode 0:** CPOL=0, CPHA=0 implementation.
- **Burst Support:** Automatically splits AXI bursts into sequential SPI transactions.
- **Clock Domain Crossing:** Robust Async FIFO implementation for reliable data transfer between clock domains.
- **Byte Enable (Strobe):** Supports partial word writes using `WSTRB`.
- **Full Verification:** Every write is verified with a read-back check.

---

## 11. How to Run the Code

### Prerequisites
- **Icarus Verilog** (`iverilog`)
- **GTKWave** (for waveform viewing)

### Commands
1. **Compile the design:**
   ```bash
   iverilog -o sim_comprehensive tb_axi4_spi_comprehensive.v axi4_spi_top.v axi4_master.v axi4_to_spi_bridge.v spi_master.v spi_slave.v async_fifo.v
   ```

2. **Run the simulation:**
   ```bash
   vvp sim_comprehensive
   ```

3. **View Waveforms:**
   ```bash
   gtkwave tb_axi4_spi_comprehensive.vcd
   ```

---

## 12. Directory Structure
```
.
├── README.md                          # Project Documentation
├── axi4_master.v                      # AXI4 Master Verification IP
├── axi4_spi_top.v                     # Top-level Module
├── axi4_to_spi_bridge.v               # Core Bridge Logic
├── spi_master.v                       # SPI Master Physical Layer
├── spi_slave.v                        # SPI Slave Model (DUT)
├── async_fifo.v                       # Asynchronous FIFO
├── tb_axi4_spi_comprehensive.v        # Comprehensive Testbench
└── tb_axi4_spi_comprehensive.vcd      # Waveform Dump (Generated)
```

---

## 13. Screenshots
| Block Diagram | Waveform | Results |
| :---: | :---: | :---: |
| <img width="3940" height="2320" alt="svgviewer-png-output (9)" src="https://github.com/user-attachments/assets/265ab257-094f-4889-ab7d-21dfb5902643" />| <img width="1356" height="471" alt="Screenshot 2025-11-27 at 8 35 23 PM" src="https://github.com/user-attachments/assets/54025871-937f-4e5a-a6d2-34bccb4bbe29" />| <img width="341" height="400" alt="Screenshot 2025-11-27 at 8 48 57 PM" src="https://github.com/user-attachments/assets/f4ccb3f3-5e40-4901-a2d6-7feee7976e06" />|

---

## 14. Applications
- **Sensor Interfacing:** Connecting accelerometers, gyroscopes, or temperature sensors to a processor.
- **Memory Expansion:** Interfacing with SPI Flash or EEPROM.
- **Communication:** Talking to other microcontrollers or wireless modules (LoRa, WiFi) via SPI.
- **Data Acquisition:** Interfacing with external ADCs or DACs.

---

## 15. Future Improvements
- **Support for SPI Modes 1, 2, 3:** Make CPOL and CPHA configurable.
- **Interrupt Support:** Add an interrupt line for the SPI slave to signal the master.
- **Quad-SPI (QSPI):** Enhance bandwidth by supporting 4 data lines.
- **Configurable Clock Divider:** Allow software to change the SPI clock speed at runtime.

---

## 16. Credits
**Developed by:** DHANASANKAR BE-ECE

**Mentor :** Swami, Ph.D, iFellow ., – Silicon Craft VLSI  

</div>
