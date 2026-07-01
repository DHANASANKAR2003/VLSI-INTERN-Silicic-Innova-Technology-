# AXI-Lite System Register Map (Programmer's Reference Manual)

This manual provides a detailed description of the register map for the AXI-Lite Register Validation system. It details the physical addresses, reset values, write masks, read permissions, and bitfield configurations.

---

## 1. System Register Map Overview

All registers are 32 bits wide. Unaligned access wraps/folds down to the aligned word base address (as defined by bits `[3:2]` of the address).

| Block | Base Address | Register Name | Offset | Access Mode | Reset Value | Write Mask | Description |
| :--- | :--- | :--- | :--- | :---: | :---: | :---: | :--- |
| **`gpio`** | `0x00000000` | [`GPIO_OUT`](#gpio_out-offset-0x00) | `0x00` | RW | `0x00000000` | `0xFFFFFFFF` | General Purpose Outputs (LEDs) |
| | | [`GPIO_IN`](#gpio_in-offset-0x04) | `0x04` | RO | `0x00000000` | `0x00000000` | General Purpose Inputs (Switches) |
| | | [`GPIO_DIR`](#gpio_dir-offset-0x08) | `0x08` | RW | `0x00000000` | `0xFFFFFFFF` | GPIO Pin Direction Control |
| | | [`SCRATCH`](#scratch-offset-0x0c) | `0x0C` | RW | `0x00000000` | `0xFFFFFFFF` | Scratchpad / Test Register |
| **`status`** | `0x00000100` | [`DEVICE_ID`](#device_id-offset-0x00) | `0x00` | RO | `0xA5A50009` | `0x00000000` | Fixed Device Identification |
| | | [`STATUS_FLAGS`](#status_flags-offset-0x04) | `0x04` | RO | `0x00000000` | `0x00000000` | Latched Bus Error Flags |
| | | [`ERROR_CLEAR`](#error_clear-offset-0x08) | `0x08` | WO | `0x00000000` | `0x0000000F` | Error Latch Reset Register |
| | | [`VERSION`](#version-offset-0x0c) | `0x0C` | RO | `0x00010000` | `0x00000000` | Firmware Core Version |
| **`timer`** | `0x00000200` | [`TIMER_CTRL`](#timer_ctrl-offset-0x00) | `0x00` | RW | `0x00000000` | `0x00000003` | Timer Enable and Mode Controls |
| | | [`TIMER_COUNT`](#timer_count-offset-0x04) | `0x04` | RO | `0x00000000` | `0x00000000` | Ticks Count Value |
| | | [`TIMER_LIMIT`](#timer_limit-offset-0x08) | `0x08` | RW | `0x00000000` | `0xFFFFFFFF` | Tick Compare Match Limit |
| | | [`TIMER_STATUS`](#timer_status-offset-0x0c) | `0x0C` | RO | `0x00000000` | `0x00000000` | Reserved |

---

## 2. Detailed Register Bitfields

### GPIO Block (Base: `0x00000000`)

#### `GPIO_OUT` (Offset: `0x00`)
Drives output logic levels for external pins. On the EDGE board, this is hardwired to the 16 onboard LEDs.
* **Bit Allocation**:
  * `[31:16]`: **Reserved**. Reads return `0`. Writes are ignored.
  * `[15:0]`: **`led_val`** (RW, default = `0x0000`). Drives physical output pins connected to the LEDs. Writing a `1` turns the corresponding LED ON.

#### `GPIO_IN` (Offset: `0x04`)
Reflects physical state of external inputs. On the EDGE board, this reads the state of the 16 slide switches.
* **Bit Allocation**:
  * `[31:16]`: **Reserved**. Reads return `0`.
  * `[15:0]`: **`switch_val`** (RO, default = switch configuration at boot). Reflects live logical input value of board slide switches (1 = switch high, 0 = switch low).

#### `GPIO_DIR` (Offset: `0x08`)
Defines the direction of the GPIO lines (used to test input/output configuration structures).
* **Bit Allocation**:
  * `[31:16]`: **Reserved**.
  * `[15:0]`: **`dir_val`** (RW, default = `0x0000`). Tristate buffer configuration (1 = Output driver enabled, 0 = High-impedance Input mode).

#### `SCRATCH` (Offset: `0x0C`)
Used for register write/read verification, bus connection checks, and pattern-bash checks.
* **Bit Allocation**:
  * `[31:0]`: **`scratch_data`** (RW, default = `0x00000000`). Read-write storage register with full toggle capability.

---

### Status Block (Base: `0x00000100`)

#### `DEVICE_ID` (Offset: `0x00`)
Device unique hardware signature.
* **Bit Allocation**:
  * `[31:0]`: **`id_val`** (RO, default = `0xA5A50009`). Fixed ID code used by host scripts to verify link connectivity.

#### `STATUS_FLAGS` (Offset: `0x04`)
Passive error status flags from the protocol monitors and timers.
* **Bit Allocation**:
  * `[31:4]`: **Reserved**. Reads return `0`.
  * `[3]`: **`reset_in_prog`** (RO). State flag showing that the hardware reset recovery logic is actively running.
  * `[2]`: **`timeout_err`** (RO). Latched when an AXI transaction fails to complete within the maximum master clock cycles timeout.
  * `[1]`: **`dec_err`** (RO). Latched when an address maps to an unmapped register block.
  * `[0]`: **`proto_err`** (RO). Latched when the protocol monitor detects an invalid channel handshake pattern.

#### `ERROR_CLEAR` (Offset: `0x08`)
Allows resetting latched flags in `STATUS_FLAGS`.
* **Bit Allocation**:
  * `[31:4]`: **Reserved**. Writes are ignored.
  * `[3]`: **`clr_reset`** (WO). Write `1` to reset `reset_in_prog`.
  * `[2]`: **`clr_timeout`** (WO). Write `1` to clear `timeout_err`.
  * `[1]`: **`clr_dec`** (WO). Write `1` to clear `dec_err`.
  * `[0]`: **`clr_proto`** (WO). Write `1` to clear `proto_err`.

#### `VERSION` (Offset: `0x0C`)
Firmware major/minor version control.
* **Bit Allocation**:
  * `[31:16]`: **`version_major`** (RO, default = `0x0001`). Displays Major release number.
  * `[15:0]`: **`version_minor`** (RO, default = `0x0000`). Displays Minor release number.

---

### Timer Block (Base: `0x00000200`)

#### `TIMER_CTRL` (Offset: `0x00`)
Controls the operation of the onboard timer.
* **Bit Allocation**:
  * `[31:2]`: **Reserved**.
  * `[1]`: **`periodic`** (RW, default = `0`). Timer reload mode (1 = Reload to 0 and loop upon expiration, 0 = Halt when count reaches limit).
  * `[0]`: **`enable`** (RW, default = `0`). Timer operational state (1 = Running, 0 = Paused).

#### `TIMER_COUNT` (Offset: `0x04`)
Live timer clock ticks counter.
* **Bit Allocation**:
  * `[31:0]`: **`count_val`** (RO, default = `0x00000000`). Live elapsed timer count. Increments on every clock cycle when `TIMER_CTRL[0]` is active.

#### `TIMER_LIMIT` (Offset: `0x08`)
The target expiration tick count.
* **Bit Allocation**:
  * `[31:0]`: **`limit_val`** (RW, default = `0x00000000`). Target value compared against `TIMER_COUNT`. When count equals limit, timer triggers expiration signal.

#### `TIMER_STATUS` (Offset: `0x0C`)
* **Bit Allocation**:
  * `[31:0]`: **Reserved** (RO, default = `0x00000000`). Reads as `0`.
