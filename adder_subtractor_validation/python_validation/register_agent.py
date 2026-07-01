# register_agent.py
# High-level register object interface mapping names to binary serial command packets.

import yaml

class RegisterAgent:
    def __init__(self, driver, yaml_path):
        self.driver = driver
        with open(yaml_path, 'r') as f:
            self.model = yaml.safe_load(f)
            
        self.blocks = self.model['blocks']

    def _get_reg_info(self, block_name, reg_name):
        if block_name not in self.blocks:
            raise ValueError(f"Block '{block_name}' not found in register model.")
        block = self.blocks[block_name]
        
        if reg_name not in block['registers']:
            raise ValueError(f"Register '{reg_name}' not found in block '{block_name}'.")
            
        reg = block['registers'][reg_name]
        abs_addr = block['base_address'] + reg['offset']
        return abs_addr, reg['mode']

    def write(self, block_name, reg_name, value) -> tuple[int, str]:
        """Performs a Write command to a register by name. Returns (echoed_value, status)."""
        try:
            addr, mode = self._get_reg_info(block_name, reg_name)
        except ValueError as e:
            return 0, str(e)
            
        # Assemble 9-byte command packet
        packet = bytearray(9)
        packet[0] = 0x57 # 'W' Opcode
        packet[1] = (addr >> 24) & 0xFF
        packet[2] = (addr >> 16) & 0xFF
        packet[3] = (addr >> 8) & 0xFF
        packet[4] = addr & 0xFF
        packet[5] = (value >> 24) & 0xFF
        packet[6] = (value >> 16) & 0xFF
        packet[7] = (value >> 8) & 0xFF
        packet[8] = value & 0xFF
        
        resp = self.driver.write_packet(bytes(packet))
        if len(resp) < 6:
            return 0, "TIMEOUT"
            
        status_code = resp[0]
        resp_val = (resp[1] << 24) | (resp[2] << 16) | (resp[3] << 8) | resp[4]
        
        status_str = "OKAY" if status_code == 0 else "ERROR"
        return resp_val, status_str

    def read(self, block_name, reg_name) -> tuple[int, str]:
        """Performs a Read command from a register by name. Returns (register_value, status)."""
        try:
            addr, mode = self._get_reg_info(block_name, reg_name)
        except ValueError as e:
            return 0, str(e)
            
        # Assemble 5-byte command packet
        packet = bytearray(5)
        packet[0] = 0x52 # 'R' Opcode
        packet[1] = (addr >> 24) & 0xFF
        packet[2] = (addr >> 16) & 0xFF
        packet[3] = (addr >> 8) & 0xFF
        packet[4] = addr & 0xFF
        
        resp = self.driver.write_packet(bytes(packet))
        if len(resp) < 6:
            return 0, "TIMEOUT"
            
        status_code = resp[0]
        resp_val = (resp[1] << 24) | (resp[2] << 16) | (resp[3] << 8) | resp[4]
        
        status_str = "OKAY" if status_code == 0 else "ERROR"
        return resp_val, status_str
