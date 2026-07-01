# register_agent.py
# High-level register access abstraction. Translates block/register names
# to AXI addresses using register_model.yaml.

import os
try:
    from .axi_lite_agent import AxiLiteAgent
except (ImportError, ValueError):
    from axi_lite_agent import AxiLiteAgent

class RegisterAgent:
    def __init__(self, axi_agent: AxiLiteAgent, model_path: str):
        self.axi_agent = axi_agent
        self.model = self._parse_yaml(model_path)
        self.blocks = self.model.get('blocks', {})

    def _parse_yaml(self, filepath: str) -> dict:
        """Lightweight native YAML parser for register specifications to avoid PyYAML dependencies."""
        blocks = {}
        cur_block = None
        cur_reg = None
        
        if not os.path.exists(filepath):
            raise FileNotFoundError(f"Register model file not found: {filepath}")

        with open(filepath, 'r') as f:
            for line in f:
                line_no_comment = line.split('#', 1)[0]
                stripped = line_no_comment.strip()
                if not stripped:
                    continue
                
                # Determine indentation level
                indent = len(line) - len(line.lstrip())
                
                if indent == 2 and stripped.endswith(':'):
                    cur_block = stripped[:-1]
                    blocks[cur_block] = {'registers': {}}
                elif indent == 4 and stripped.startswith('base_addr:'):
                    val = stripped.split(':', 1)[1].strip()
                    blocks[cur_block]['base_addr'] = int(val, 16)
                elif indent == 6 and stripped.endswith(':'):
                    cur_reg = stripped[:-1]
                    blocks[cur_block]['registers'][cur_reg] = {}
                elif indent == 8 and ':' in stripped:
                    key, val = stripped.split(':', 1)
                    key = key.strip()
                    val = val.strip().strip('"')
                    if key == 'offset':
                        blocks[cur_block]['registers'][cur_reg]['offset'] = int(val, 16)
                    elif key == 'mode':
                        blocks[cur_block]['registers'][cur_reg]['mode'] = val
                    elif key == 'reset':
                        blocks[cur_block]['registers'][cur_reg]['reset'] = int(val, 16)
        return {'blocks': blocks}

    def get_register_address(self, block_name: str, reg_name: str) -> int:
        """Computes the absolute byte address of a register."""
        block = self.blocks.get(block_name.lower())
        if not block:
            raise KeyError(f"Block '{block_name}' not found in register model.")
        
        reg = block['registers'].get(reg_name.upper())
        if not reg:
            raise KeyError(f"Register '{reg_name}' not found in block '{block_name}'.")
            
        return block['base_addr'] + reg['offset']

    def write(self, block_name: str, reg_name: str, value: int) -> tuple[int, str]:
        """Writes to a register by block and register name."""
        addr = self.get_register_address(block_name, reg_name)
        return self.axi_agent.write(addr, value)

    def read(self, block_name: str, reg_name: str) -> tuple[int, str]:
        """Reads a register by block and register name."""
        addr = self.get_register_address(block_name, reg_name)
        return self.axi_agent.read(addr)

    def get_mode(self, block_name: str, reg_name: str) -> str:
        """Returns the access policy (RW, RO, WO) of a register."""
        block = self.blocks.get(block_name.lower())
        if block:
            reg = block['registers'].get(reg_name.upper())
            if reg:
                return reg['mode']
        return "UNKNOWN"

    def get_reset_value(self, block_name: str, reg_name: str) -> int:
        """Returns the expected reset value of a register."""
        block = self.blocks.get(block_name.lower())
        if block:
            reg = block['registers'].get(reg_name.upper())
            if reg:
                return reg['reset']
        return 0
