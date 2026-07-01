# YAML Register Model Specification

The register validation framework uses a unified YAML file (`register_model.yaml`) as the single source of truth for register configurations. This document details the schema of the YAML file and how it is processed by the verification scripts.

---

## 1. Schema Definition

The YAML structure contains a root key called `blocks`. Under `blocks`, each entry defines a sub-module base address and its contained register objects.

### Fields defined per Register:
* **`offset`**: Relative hex offset address inside the block.
* **`mode`**: Target access capability constraint. Valid values are:
  * `"RW"`: Read-Write.
  * `"RO"`: Read-Only.
  * `"WO"`: Write-Only.
* **`reset`**: 32-bit hex default value expected immediately after reset.
* **`description`**: Descriptive comment string for reporting.

---

## 2. Structural Example

Below is the YAML specification for the `timer` register block:

```yaml
blocks:
  timer:
    base_addr: 0x00000200
    registers:
      TIMER_CTRL:
        offset: 0x00
        mode: "RW"
        reset: 0x00000000
        description: "Timer control (bit0=enable, bit1=periodic)."
      TIMER_COUNT:
        offset: 0x04
        mode: "RO"
        reset: 0x00000000
        description: "Live timer counter register."
```

---

## 3. Parsing Mechanism

The parsing is handled by the **`RegisterAgent`** class inside `register_agent.py`. It executes the following steps:

1. **Loads File**: Uses the standard Python `yaml.safe_load()` library to parse the file into a nested Python dictionary.
2. **Path Cleaning**: Dynamically filters out comment lines or headers to avoid parsing errors.
3. **Register Mapping**: Flatten lists to match full physical addresses:
   $$\text{Physical Address} = \text{Block Base Address} + \text{Register Offset}$$
4. **Validation Hooks**: When tests execute, the test files query the model to determine assertions:
   * During **Reset Values verification**, it iterates through every register, reads the address, and asserts that the returned value matches `reset`.
   * During **Access Policy verification**, it attempts writes to RO registers and ensures the value does not deviate from the YAML-defined `reset` or previous value.
   * During **Bit-Bash tests**, it looks for the `"RW"` mode tag to determine which registers are eligible for bit toggle sweeps.
