# axi_lite_agent.py
# Mid-level agent wrapping raw binary serialization into simple read/write calls

import time
try:
    from .serial_driver import SerialDriver
except (ImportError, ValueError):
    from serial_driver import SerialDriver

class AxiLiteAgent:
    def __init__(self, driver: SerialDriver):
        self.driver = driver

    def write(self, addr: int, data: int) -> tuple[int, str]:
        """
        Performs an AXI-Lite write transaction.
        Returns: (resp_data, status_string)
        """
        # Pack command packet (9 bytes):
        # [0]   Opcode = 0x57 (W)
        # [1:4] Address (32-bit big-endian)
        # [5:8] Data (32-bit big-endian)
        packet = bytearray()
        packet.append(0x57) # OPCODE_WRITE
        packet.extend(addr.to_bytes(4, byteorder='big'))
        packet.extend(data.to_bytes(4, byteorder='big'))

        try:
            response = self.driver.transmit_packet(packet)
            status_code = response[0]
            echoed_data = int.from_bytes(response[1:5], byteorder='big')
            status_str = self.decode_status(status_code)
            return echoed_data, status_str
        except Exception as e:
            return 0, f"DRIVER_ERROR: {str(e)}"

    def read(self, addr: int) -> tuple[int, str]:
        """
        Performs an AXI-Lite read transaction.
        Returns: (read_data, status_string)
        """
        # Pack command packet (5 bytes):
        # [0]   Opcode = 0x52 (R)
        # [1:4] Address (32-bit big-endian)
        packet = bytearray()
        packet.append(0x52) # OPCODE_READ
        packet.extend(addr.to_bytes(4, byteorder='big'))

        try:
            response = self.driver.transmit_packet(packet)
            status_code = response[0]
            read_data = int.from_bytes(response[1:5], byteorder='big')
            status_str = self.decode_status(status_code)
            return read_data, status_str
        except Exception as e:
            return 0, f"DRIVER_ERROR: {str(e)}"

    def decode_status(self, code: int) -> str:
        """Translates AXI status codes into human readable strings."""
        if code == 0x00:
            return "OKAY"
        elif code == 0x01:
            return "SLVERR"
        elif code == 0x02:
            return "DECERR"
        elif code == 0x03:
            return "TIMEOUT"
        else:
            return f"UNKNOWN_ERROR(0x{code:02x})"
