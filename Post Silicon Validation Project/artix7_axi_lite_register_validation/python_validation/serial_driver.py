# serial_driver.py
# Low-level UART driver for register validation.
# Integrates standard pyserial and a complete register-level simulation.

import sys
import time

# Try to import serial, but fall back to mock mode if not present
try:
    import serial
    SERIAL_AVAILABLE = True
except ImportError:
    SERIAL_AVAILABLE = False

class SerialDriver:
    def __init__(self, port, baudrate, timeout=1.0, mock_mode=True):
        self.port = port
        self.baudrate = baudrate
        self.timeout = timeout
        # Force mock mode if pyserial is not installed
        self.mock_mode = mock_mode or not SERIAL_AVAILABLE
        self.ser = None
        
        if not SERIAL_AVAILABLE and not mock_mode:
            print("WARNING: pyserial is not installed. Forcing mock_mode=True.")
            self.mock_mode = True

        # Simulated FPGA Register Space State (Mock Mode)
        self.mock_regs = {
            # GPIO Block (0x00)
            0x00000000: 0x00000000, # GPIO_OUT (RW)
            0x00000004: 0x00000000, # GPIO_IN (RO)
            0x00000008: 0x00000000, # GPIO_DIR (RW)
            0x0000000C: 0x00000000, # SCRATCH (RW)
            
            # Status Block (0x100)
            0x00000100: 0xA5A50009, # DEVICE_ID (RO)
            0x00000104: 0x00000000, # STATUS_FLAGS (RO)
            0x00000108: 0x00000000, # ERROR_CLEAR (WO)
            0x0000010C: 0x00000000, # VERSION (RO) (will set to 0x00010000 on reset)
            
            # Timer Block (0x200)
            0x00000200: 0x00000000, # TIMER_CTRL (RW)
            0x00000204: 0x00000000, # TIMER_COUNT (RO)
            0x00000208: 0x00000000, # TIMER_LIMIT (RW)
            0x0000020C: 0x00000000, # TIMER_STATUS (RO)
        }
        
        self.mock_reset()

    def mock_reset(self):
        """Reset mock register values to their specified defaults"""
        self.mock_regs[0x00000000] = 0x00000000
        self.mock_regs[0x00000004] = 0x00000000 # will reflect switches
        self.mock_regs[0x00000008] = 0x00000000
        self.mock_regs[0x0000000C] = 0x00000000
        
        self.mock_regs[0x00000100] = 0xA5A50009
        self.mock_regs[0x00000104] = 0x00000000
        self.mock_regs[0x00000108] = 0x00000000
        self.mock_regs[0x0000010C] = 0x00010000
        
        self.mock_regs[0x00000200] = 0x00000000
        self.mock_regs[0x00000204] = 0x00000000
        self.mock_regs[0x00000208] = 0x00000000
        self.mock_regs[0x0000020C] = 0x00000000
        
        self.last_reset_time = time.time()
        self.reset_count = getattr(self, 'reset_count', 0) + 1

    def open(self):
        if self.mock_mode:
            # print("[MOCK] Serial connection opened on port:", self.port)
            return True
        try:
            self.ser = serial.Serial(self.port, self.baudrate, timeout=self.timeout)
            return True
        except Exception as e:
            print(f"ERROR: Failed to open serial port {self.port}: {e}")
            return False

    def close(self):
        if self.mock_mode:
            # print("[MOCK] Serial connection closed.")
            return
        if self.ser and self.ser.is_open:
            self.ser.close()

    def transmit_packet(self, packet):
        """Sends raw byte packets over the serial connection."""
        if self.mock_mode:
            return self._mock_transceive(packet)
            
        if not self.ser or not self.ser.is_open:
            raise RuntimeError("Serial port not open.")
        
        self.ser.write(packet)
        self.ser.flush()
        
        # Read AXI Response: expects exactly 6 bytes (status + 4 data bytes + opcode)
        response = self.ser.read(6)
        if len(response) != 6:
            raise TimeoutError(f"UART timed out waiting for response (got {len(response)} bytes).")
            
        return response

    def _mock_transceive(self, packet):
        """Simulates internal hardware register logic, interconnect decoding, and errors."""
        opcode = packet[0]
        addr = int.from_bytes(packet[1:5], byteorder='big')
        
        # Read: 5 bytes packet. Write: 9 bytes packet.
        if opcode == 0x57: # Write
            wdata = int.from_bytes(packet[5:9], byteorder='big')
            resp_opcode = 0x57
        elif opcode == 0x52: # Read
            wdata = 0
            resp_opcode = 0x52
        else:
            # Unrecognized opcode
            return bytes([0x01, 0x00, 0x00, 0x00, 0x00, opcode])

        # Increment timer count if enabled
        if self.mock_regs[0x00000200] & 0x01: # timer enable bit
            limit = self.mock_regs[0x00000208]
            count = self.mock_regs[0x00000204]
            # Mock timer increment on every register access transaction
            count += 1
            if limit > 0 and count >= limit:
                if self.mock_regs[0x00000200] & 0x02: # periodic bit
                    count = 0
                else:
                    count = limit
                # Set latched protocol_error / timer flag (bit 0 of status flags is protocol error, but let's set mock flag)
                # Let's say bit 0 is protocol error, bit 1 is decode error, bit 2 is timeout error, bit 3 is reset_in_progress
                # (actually status_flags are wire inputs from monitors)
                pass
            self.mock_regs[0x00000204] = count

        # Determine register block base and validation
        # Address Decode check (0x0 to 0xFF, 0x100 to 0x1FF, 0x200 to 0x2FF are valid)
        is_gpio = (addr >= 0x00000000 and addr <= 0x000000FF)
        is_status = (addr >= 0x00000100 and addr <= 0x000001FF)
        is_timer = (addr >= 0x00000200 and addr <= 0x000002FF)
        
        if not (is_gpio or is_status or is_timer):
            # DECERR (decode error = 0x02)
            self.mock_regs[0x00000104] |= 0x02 # Latch Decode Error flag in STATUS_FLAGS
            return bytes([0x02, 0x00, 0x00, 0x00, 0x00, resp_opcode])
            
        # AXI-Lite registers ignore byte-alignment on real hardware and wrap offsets to multiples of 4 within the 16-byte window (0x00, 0x04, 0x08, 0x0C).
        # We align the offset to match the RTL's address folding behavior:
        base_addr = (addr >> 8) << 8
        offset = addr & 0xFF
        aligned_offset = offset & 0x0C
        aligned_addr = base_addr + aligned_offset

        status = 0x00 # OKAY
        rdata = 0
        
        if opcode == 0x57: # WRITE
            # Access policy check
            if is_gpio:
                if aligned_offset == 0x04: # GPIO_IN (RO)
                    pass # ignore write
                elif aligned_offset == 0x00: # GPIO_OUT (RW)
                    self.mock_regs[aligned_addr] = wdata
                else: # GPIO_DIR, SCRATCH (RW)
                    self.mock_regs[aligned_addr] = wdata
            elif is_status:
                if aligned_offset == 0x08: # ERROR_CLEAR (WO)
                    # Clear latched error bits (bit0 = protocol, bit1 = decode, bit2 = timeout)
                    # Writing a 1 clears that bit in STATUS_FLAGS
                    self.mock_regs[0x00000104] &= (~wdata & 0x0F)
                else: # DEVICE_ID, VERSION, STATUS_FLAGS (RO)
                    pass # ignore write
            elif is_timer:
                if aligned_offset in [0x04, 0x0c]: # TIMER_COUNT, TIMER_STATUS (RO)
                    pass # ignore write
                else: # TIMER_CTRL, TIMER_LIMIT (RW)
                    self.mock_regs[aligned_addr] = wdata
                    
            rdata = wdata # Write echo
            
        else: # READ (0x52)
            if is_gpio:
                rdata = self.mock_regs[aligned_addr]
            elif is_status:
                if aligned_offset == 0x08: # ERROR_CLEAR (WO)
                    rdata = 0 # Reads return 0
                else:
                    rdata = self.mock_regs[aligned_addr]
            elif is_timer:
                rdata = self.mock_regs[aligned_addr]

        # Simulate timeout injection (special control for testing)
        # In a real board, the error injector can block awready, triggering master timeout (SLVERR).
        # We can simulate this if we read/write to the special trigger address 0xCC (which wraps to offset 0x0C).
        if addr == 0x000000CC:
            status = 0x03 # TIMEOUT (SLVERR on master side, reports TIMEOUT on UART status)
            rdata = 0
            self.mock_regs[0x00000104] |= 0x04 # Latch Timeout Error flag in STATUS_FLAGS

        # Return mock packet
        rbytes = rdata.to_bytes(4, byteorder='big')
        return bytes([status]) + rbytes + bytes([resp_opcode])
