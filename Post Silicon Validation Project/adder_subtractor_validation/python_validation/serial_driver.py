# serial_driver.py
# Low-level communication driver with built-in mock mode.
# Simplified protocol: Sends 3 bytes [OP_A, OP_B, CTRL] and reads 2 bytes [RESULT, CARRY_BORROW].

import time

class SerialDriver:
    def __init__(self, port="MOCK", baudrate=115200, mock_mode=False):
        self.port = port
        self.baudrate = baudrate
        self.mock_mode = mock_mode or (port == "MOCK")
        self.ser = None

    def open(self) -> bool:
        if self.mock_mode:
            print(f"[DRV] Opened MOCK Serial Port connection (Baud: {self.baudrate})")
            return True
        
        try:
            import serial
            self.ser = serial.Serial(self.port, self.baudrate, timeout=1.0)
            print(f"[DRV] Opened physical Serial Port: {self.port} (Baud: {self.baudrate})")
            return True
        except Exception as e:
            print(f"[DRV] FAILED to open serial port {self.port}: {e}")
            print("[DRV] Falling back to MOCK mode...")
            self.mock_mode = True
            return True

    def close(self):
        if self.ser and self.ser.is_open:
            self.ser.close()
        print("[DRV] Closed Serial connection.")

    def write_packet(self, payload: bytes) -> bytes:
        """Sends a 3-byte command packet [A, B, CTRL] and waits to receive a 2-byte response."""
        if self.mock_mode:
            return self._handle_mock_transaction(payload)
            
        try:
            self.ser.write(payload)
            self.ser.flush()
            # Wait for 2-byte response
            resp = self.ser.read(2)
            if len(resp) < 2:
                print("[DRV] Warning: Timeout waiting for serial response (Received less than 2 bytes).")
            return resp
        except Exception as e:
            print(f"[DRV] Serial transaction error: {e}")
            return b""

    def _handle_mock_transaction(self, payload: bytes) -> bytes:
        """Simulates the simplified 8-bit Adder/Subtractor hardware response."""
        if len(payload) < 3:
            return b""
            
        a = payload[0]
        b = payload[1]
        ctrl = payload[2]
        
        sub_sel = ctrl & 1
        if sub_sel == 0:
            # Addition
            res = a + b
            math_result = res & 0xFF
            carry = 1 if res > 255 else 0
        else:
            # Subtraction
            res = a - b
            math_result = res & 0xFF
            borrow = 1 if a < b else 0
            carry = borrow
            
        resp = bytearray(2)
        resp[0] = math_result
        resp[1] = carry
        
        # Simulate physical UART delay
        time.sleep(0.001)
        return bytes(resp)
