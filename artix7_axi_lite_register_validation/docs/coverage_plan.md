# AXI-Lite Register Validation Coverage Plan

This document details the strategies and metrics used to measure the completeness of the post-silicon register validation suite. 

---

## 1. Coverage Metrics Defined

To achieve full verification sign-off, the framework collects and calculates coverage in three categories:

### A. Register Access Coverage
Ensures that every defined register in the system has been targeted by at least one transaction during the regression run.
* **Calculation**:
  $$\text{Access Coverage \%} = \frac{\text{Actual Read/Write Transactions}}{\text{Expected Read/Write Targets}} \times 100$$
* **Requirements**:
  * **Read-Write (RW) Registers**: Must be targeted by at least one write and one read.
  * **Read-Only (RO) Registers**: Must be targeted by at least one read.
  * **Write-Only (WO) Registers**: Must be targeted by at least one write.

### B. Access Policy Coverage
Validates that the design correctly handles illegal operations according to its access policies.
* **Target Actions**:
  * Verify that write operations to **Read-Only** (RO) registers (e.g., `DEVICE_ID`, `VERSION`) do not change the internal state.
  * Verify that read operations from **Write-Only** (WO) registers (e.g., `ERROR_CLEAR`) return default values (e.g., `0x00000000`) and do not leak register states.
  * Verify that **Read-Write** (RW) registers correctly retain modified values.

### C. Bit Toggle Coverage
Ensures that every single physical data bit of read-write registers is free of stuck-at-0 and stuck-at-1 faults.
* **Methodology**: For every 32-bit RW register, we track whether each individual bit position has transitioned:
  1. From `0 -> 1` (Bit High Coverage).
  2. From `1 -> 0` (Bit Low Coverage).
* **Targets**: There are 64 toggle targets (32 bits high + 32 bits low) per read-write register.
* **Calculation**:
  $$\text{Bit Toggle Coverage \%} = \frac{\sum(\text{Bits Written High}) + \sum(\text{Bits Written Low})}{64 \times \text{Number of RW Registers}} \times 100$$

---

## 2. Register Hierarchy and Coverage Points

The system tracks coverage points across three functional blocks:

| Block Name | Register Name | Address Offset | Mode | Access Coverage Targets | Toggle Coverage Targets |
| :--- | :--- | :--- | :--- | :---: | :---: |
| **`gpio`** | `GPIO_OUT` | `0x00` | RW | Read & Write | 64 bits |
| | `GPIO_IN` | `0x04` | RO | Read | N/A |
| | `GPIO_DIR` | `0x08` | RW | Read & Write | 64 bits |
| | `SCRATCH` | `0x0C` | RW | Read & Write | 64 bits |
| **`status`** | `DEVICE_ID` | `0x00` | RO | Read | N/A |
| | `STATUS_FLAGS`| `0x04` | RO | Read | N/A |
| | `ERROR_CLEAR` | `0x08` | WO | Write | N/A |
| | `VERSION` | `0x0C` | RO | Read | N/A |
| **`timer`** | `TIMER_CTRL` | `0x00` | RW | Read & Write | 64 bits |
| | `TIMER_COUNT` | `0x04` | RO | Read | N/A |
| | `TIMER_LIMIT` | `0x08` | RW | Read & Write | 64 bits |
| | `TIMER_STATUS`| `0x0C` | RO | Read | N/A |

---

## 3. Coverage Collection Flow

1. **Transaction Interception**: The `CoverageCollector` class inside `coverage_collector.py` acts as a passive monitor. Whenever the serial driver completes a read or write operation, it logs the transaction:
   * `log_read(block, register, value)`
   * `log_write(block, register, value)`
2. **Bitmask Accumulation**:
   * For writes to RW registers, the written pattern is bitwise-ORed into `bits_written_one` and the inverted pattern is ORed into `bits_written_zero`.
3. **Report Generation**: At the end of the run, the database is parsed to calculate the final percentage metrics, which are dumped into `report.html` and the dashboard.

---

## 4. Sign-Off Thresholds

For production sign-off, the following criteria must be met:
* **Register Access Coverage**: **100%** (All 12 registers read/written matching their access mode).
* **Access Policy Coverage**: **100%** (No violations recorded).
* **Bit Toggle Coverage**: **100%** (All 32 bits of every RW register written to both `1` and `0`).
* **Regressions**: **7 / 7** directed tests must pass cleanly.
