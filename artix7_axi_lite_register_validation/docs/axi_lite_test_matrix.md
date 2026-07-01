# AXI-Lite Register Validation Test Matrix (Verification Mapping)

This matrix maps each functional check to its respective Python script, detailing the exact test sequences, inputs, and assertion conditions.

---

## 1. Test Case Summary Table

| Test ID | Title | Target File | Target Registers | Assertions / Verification Scope |
| :--- | :--- | :--- | :--- | :--- |
| **TC-01** | Reset Values Check | `test_reset_values.py` | All Registers | Verify all registers read back default spec values upon reset. |
| **TC-02** | Read-Write Loopback | `test_read_write.py` | `SCRATCH`, `GPIO_OUT`, `TIMER_LIMIT`, `GPIO_DIR` | Write and read back pattern data (`0x55555555`, `0xAAAAAAAA`). |
| **TC-03** | Read-Only Write Block | `test_read_only_write.py`| `DEVICE_ID`, `VERSION`, `GPIO_IN`, `TIMER_COUNT` | Attempt write to RO, verify write is ignored and value is unchanged. |
| **TC-04** | Permissions Boundary | `test_access_permissions.py`| All Registers | Check read-write, read-only, and write-only behavior across registers. |
| **TC-05** | Bit-Bash Sweep | `test_bit_bash.py` | `SCRATCH`, `GPIO_OUT`, `TIMER_LIMIT`, `GPIO_DIR` | Walking 1s/0s on all bit positions. Verify no stuck-at or coupling faults. |
| **TC-06** | Address Folding & Out-of-Bounds | `test_illegal_access.py` | Out-of-bounds, unaligned offsets | Verify invalid base address returns `DECERR` and unaligned offsets fold. |
| **TC-07** | Reset Recovery & Clear | `test_reset_recovery.py`| `ERROR_CLEAR`, `STATUS_FLAGS` | Latch errors, trigger clears, verify sticky flags behave correctly. |

---

## 2. Detailed Test Specifications

### TC-01: Reset Values Check
* **Objective**: Confirm register values immediately after boot.
* **Test Sequence**:
  1. Boot the board (or execute reset command).
  2. Perform sequential read transactions to all 12 registers.
  3. Compare the read value against the default values defined in `register_model.yaml`.
* **Assertion Condition**:
  `read_value == yaml_reset_value`
* **Pass Criteria**: 100% of registers match their default reset value.

### TC-02: Read-Write Loopback
* **Objective**: Test write command stability and memory cell retention.
* **Test Sequence**:
  1. Generate random 32-bit words or specific patterns (`0x55555555`, `0xAAAAAAAA`, `0x00000000`, `0xFFFFFFFF`).
  2. Write to `SCRATCH`, `GPIO_OUT`, `TIMER_LIMIT`, and `GPIO_DIR`.
  3. Read back each register.
* **Assertion Condition**:
  `read_value == written_value`
* **Pass Criteria**: Value is preserved. Bus returns `OKAY` status code `0x00`.

### TC-03: Read-Only Write Block
* **Objective**: Ensure write operations cannot modify Read-Only status registers.
* **Test Sequence**:
  1. Read the initial value of a Read-Only register (e.g., `DEVICE_ID` = `0xA5A50009`).
  2. Write `0x00000000` and `0xFFFFFFFF` to the register.
  3. Read the value again.
* **Assertion Condition**:
  `post_write_value == initial_value`
* **Pass Criteria**: Value remains unchanged. Write does not corrupt data.

### TC-04: Permissions Boundary
* **Objective**: Verify that RW, RO, and WO constraints are strictly enforced across all blocks.
* **Test Sequence**:
  1. Write to RW registers, check that values update.
  2. Write to RO registers, check that values remain unchanged.
  3. Read from WO register (`ERROR_CLEAR`), check that it returns `0x00000000` (or `0`).
* **Assertion Condition**:
  `read(ERROR_CLEAR) == 0` and `write(RO) is ignored` and `write(RW) succeeds`.
* **Pass Criteria**: All three criteria pass without raising unexpected bus errors.

### TC-05: Bit-Bash Sweep (Stuck-At Fault Test)
* **Objective**: Check that every bit of RW registers can transition `0->1` and `1->0` independently.
* **Test Sequence**:
  1. For each target register, write a walking-1 pattern (bit 0 is `1`, others `0`; then bit 1 is `1`, others `0`... up to bit 31). Read back and verify after each write.
  2. Repeat with a walking-0 pattern (bit 0 is `0`, others `1`; then bit 1 is `0`, others `1`... up to bit 31).
* **Assertion Condition**:
  `read_value == walking_pattern`
* **Pass Criteria**: No bit is stuck-at `0` or stuck-at `1`. All 64 transitions per register pass.

### TC-06: Address Folding & Out-of-Bounds
* **Objective**: Verify address decode boundaries and unaligned access handling.
* **Test Sequence**:
  1. Attempt write and read to unmapped addresses (e.g. `0x00000300`, `0x00000400`). Verify `DECERR` status code `0x02` is returned.
  2. Attempt access to unaligned addresses (e.g. `0x00000002`). Verify it maps to the aligned word base address `0x00000000` and reads/writes to `GPIO_OUT` (Address Folding).
* **Assertion Condition**:
  `status(unmapped_access) == 0x02` and `read(0x02) == read(0x00)`
* **Pass Criteria**: Unmapped regions return decode error. Unaligned addresses fold down to nearest word boundary.

### TC-07: Reset Recovery & Clear
* **Objective**: Latch and clear error flags inside the status block.
* **Test Sequence**:
  1. Trigger a decode error (by reading from an unmapped address).
  2. Read `STATUS_FLAGS` and verify that bit 1 (`dec_err`) is latched high (`1`).
  3. Write `0x00000002` (bit 1 high) to `ERROR_CLEAR`.
  4. Read `STATUS_FLAGS` again. Verify bit 1 has reset to `0`.
* **Assertion Condition**:
  `dec_err_latched == 1` then `dec_err_cleared == 0`
* **Pass Criteria**: Error status flag latches and clears successfully.
