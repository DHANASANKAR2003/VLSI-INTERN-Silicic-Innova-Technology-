# coverage_collector.py
# Tracks register and bit-bash coverage across test runs.

class CoverageCollector:
    def __init__(self, register_model: dict):
        self.blocks = register_model.get('blocks', {})
        self.coverage_db = {}
        
        # Initialize database structures
        for block_name, block_info in self.blocks.items():
            self.coverage_db[block_name] = {}
            for reg_name, reg_info in block_info['registers'].items():
                self.coverage_db[block_name][reg_name] = {
                    'read_seen': False,
                    'write_seen': False,
                    'mode': reg_info['mode'],
                    # 32-bit tracking vectors for toggling
                    'bits_written_one': 0x00000000,
                    'bits_written_zero': 0x00000000
                }

    def log_read(self, block_name: str, reg_name: str, read_value: int):
        """Logs a read operation on a register."""
        block_name = block_name.lower()
        reg_name = reg_name.upper()
        if block_name in self.coverage_db and reg_name in self.coverage_db[block_name]:
            self.coverage_db[block_name][reg_name]['read_seen'] = True
            
            # For read-only registers, read data can also be checked for bit toggling
            if self.coverage_db[block_name][reg_name]['mode'] == 'RO':
                # Track what bits were read as 1 and 0
                self.coverage_db[block_name][reg_name]['bits_written_one'] |= read_value
                self.coverage_db[block_name][reg_name]['bits_written_zero'] |= (~read_value & 0xFFFFFFFF)

    def log_write(self, block_name: str, reg_name: str, write_value: int):
        """Logs a write operation on a register."""
        block_name = block_name.lower()
        reg_name = reg_name.upper()
        if block_name in self.coverage_db and reg_name in self.coverage_db[block_name]:
            self.coverage_db[block_name][reg_name]['write_seen'] = True
            
            # Track bit toggles (whether each bit of a 32-bit word was written with 1 and 0)
            if self.coverage_db[block_name][reg_name]['mode'] in ['RW', 'WO']:
                self.coverage_db[block_name][reg_name]['bits_written_one'] |= write_value
                self.coverage_db[block_name][reg_name]['bits_written_zero'] |= (~write_value & 0xFFFFFFFF)

    def calculate_coverage(self) -> dict:
        """Calculates access policies and bit toggle coverages."""
        total_registers = 0
        total_read_points = 0
        total_write_points = 0
        
        reads_covered = 0
        writes_covered = 0
        
        total_bits_to_toggle = 0
        bits_toggled = 0
        
        block_coverage = {}

        for block_name, registers in self.coverage_db.items():
            block_regs = len(registers)
            block_reads_req = 0
            block_writes_req = 0
            block_reads_cov = 0
            block_writes_cov = 0
            block_bits_req = 0
            block_bits_cov = 0

            for reg_name, stats in registers.items():
                total_registers += 1
                mode = stats['mode']
                
                # Setup targets based on mode
                if mode in ['RW', 'RO']:
                    total_read_points += 1
                    block_reads_req += 1
                    if stats['read_seen']:
                        reads_covered += 1
                        block_reads_cov += 1
                        
                if mode in ['RW', 'WO']:
                    total_write_points += 1
                    block_writes_req += 1
                    if stats['write_seen']:
                        writes_covered += 1
                        block_writes_cov += 1
                
                # Bit-bash coverage (only meaningful for RW registers)
                if mode == 'RW':
                    total_bits_to_toggle += 64 # 32 bits high, 32 bits low
                    block_bits_req += 64
                    
                    # Count how many bits were toggled high and low
                    ones = bin(stats['bits_written_one']).count('1')
                    zeros = bin(stats['bits_written_zero']).count('1')
                    
                    # Cap at 32 each
                    ones = min(ones, 32)
                    zeros = min(zeros, 32)
                    
                    bits_toggled += (ones + zeros)
                    block_bits_cov += (ones + zeros)

            # Block level summary
            block_tot_points = block_reads_req + block_writes_req
            block_cov_points = block_reads_cov + block_writes_cov
            block_acc_pct = (block_cov_points / block_tot_points * 100.0) if block_tot_points > 0 else 100.0
            block_bit_pct = (block_bits_cov / block_bits_req * 100.0) if block_bits_req > 0 else 100.0
            
            block_coverage[block_name] = {
                'access_percent': block_acc_pct,
                'bit_percent': block_bit_pct
            }

        # Overall summary
        total_access_points = total_read_points + total_write_points
        access_covered = reads_covered + writes_covered
        
        overall_access_pct = (access_covered / total_access_points * 100.0) if total_access_points > 0 else 100.0
        overall_bit_pct = (bits_toggled / total_bits_to_toggle * 100.0) if total_bits_to_toggle > 0 else 100.0

        return {
            'overall_access_percent': overall_access_pct,
            'overall_bit_percent': overall_bit_pct,
            'blocks': block_coverage,
            'details': self.coverage_db
        }
