# AXI-Lite Register Validation Regression Report
**Generated:** 2026-06-29 16:25:58 | **Status:** PASS

## Summary
| Metric | Value |
|---|---|
| **Total Tests** | 7 |
| **Passed Tests** | 7 |
| **Failed Tests** | 0 |
| **Register Access Coverage** | 100.0% |
| **Bit Bash Toggle Coverage** | 100.0% |

## Test Details
| Test Case | Description | Status | Time (s) | Notes |
|---|---|---|---|---|
| TC-01: Reset Values Verification | Checks initial register values against default YAML settings. | **PASSED** | 0.000 | All register reset values verified successfully. |
| TC-02: Write/Read Back RW Registers | Verifies write and read cycles on RW fields. | **PASSED** | 0.000 | All RW registers verified successfully. |
| TC-03: Read-Only Registers Write Check | Verifies that writes to RO registers are dropped. | **PASSED** | 0.000 | RO register write policy verified successfully (all writes ignored). |
| TC-04: RW / RO / WO Permission Verification | Tests read and write constraints per register type. | **PASSED** | 0.000 | All access permissions (RW, RO, WO) verified successfully. |
| TC-05: 32-Bit Toggle Bit-Bash Sweep | Executes walking 1/0 checks on all RW bits. | **PASSED** | 0.001 | All RW registers successfully passed the 32-bit walking 1/0 bit-bash verification. |
| TC-06: Out-of-Bounds Address Decoding (DECERR) | Validates error status for illegal address spaces. | **PASSED** | 0.000 | Interconnect correctly rejected unmapped requests with DECERR and handled unaligned offsets via address folding. |
| TC-07: Reset Recovery Check | Simulates soft resets and checks post-reset stability. | **PASSED** | 0.000 | Reset recovery successful. Registers returned to default and status flags cleared. |

## Block Coverage Details
| Block | Access Coverage | Bit Toggle Coverage |
|---|---|---|
| GPIO | 100.0% | 100.0% |
| STATUS | 100.0% | 100.0% |
| TIMER | 100.0% | 100.0% |