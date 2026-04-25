"""
Configuration file parsing and management for the X-ray spectroscopy pipeline.
"""

import os
import re
from typing import Dict, Optional, Tuple, List
from pathlib import Path


class ConfigManager:
    """
    Manages configuration file parsing and provides access to configuration parameters.
    
    The config.info file is a two-column formatted file with NAME and FLAG columns.
    Mandatory parameters: Atom_number_range_A, Atom_number_range_B, core_MO_range,
                         exc_state_range, soc_option, orca_output
    Optional parameters: spectra_option, external_MO_file, atm_core, wave_f_type,
                        input_path, output_path
    """
    
    MANDATORY_FLAGS = {
        'Atom_number_range_A': str,
        'Atom_number_range_B': str,
        'core_MO_range': str,
        'exc_state_range': str,
        'soc_option': int,
        'orca_output': str,
    }
    
    OPTIONAL_FLAGS = {
        'spectra_option': (int, 0),
        'external_MO_file': (str, None),
        'atm_core': (str, 'C'),
        'wave_f_type': (str, 's'),
        'input_path': (str, None),
        'output_path': (str, None),
    }
    
    def __init__(self, config_file: str = "config.info"):
        """
        Initialize ConfigManager with a config file.
        
        Args:
            config_file: Path to the configuration file (default: config.info)
        """
        self.config_file = config_file
        self.config: Dict[str, any] = {}
        self.errors: List[str] = []
        self.warnings: List[str] = []
    
    def load(self) -> bool:
        """
        Load and parse the configuration file.
        
        Returns:
            bool: True if successful, False if errors occurred
        """
        if not os.path.isfile(self.config_file):
            self.errors.append(f"Config file not found: {self.config_file}")
            return False
        
        try:
            with open(self.config_file, 'r') as f:
                self._parse_config(f.read())
            return len(self.errors) == 0
        except Exception as e:
            self.errors.append(f"Failed to read config file: {str(e)}")
            return False
    
    def _parse_config(self, content: str) -> None:
        """
        Parse configuration file content.
        
        Args:
            content: File content as string
        """
        lines = content.strip().split('\n')
        in_optional = False
        
        for line in lines:
            line = line.strip()
            
            # Skip empty lines and dashes/borders
            if not line or line.startswith('-') or line.startswith('|'):
                if 'Optional' in line:
                    in_optional = True
                continue
            
            # Skip headers
            if 'NAME' in line and 'FLAG' in line:
                continue
            
            # Parse key=value pairs
            if '=' in line:
                key, value = line.split('=', 1)
                key = key.strip()
                value = value.strip()
                self.config[key] = value
    
    def get(self, key: str, default: Optional[str] = None) -> Optional[str]:
        """
        Get a configuration value.
        
        Args:
            key: Configuration key
            default: Default value if key not found
            
        Returns:
            Configuration value or default
        """
        return self.config.get(key, default)
    
    def get_mandatory(self) -> Dict[str, str]:
        """Get all mandatory configuration parameters."""
        return {k: self.config[k] for k in self.MANDATORY_FLAGS if k in self.config}
    
    def get_optional(self) -> Dict[str, str]:
        """Get all optional configuration parameters."""
        result = {}
        for key, (dtype, default) in self.OPTIONAL_FLAGS.items():
            result[key] = self.config.get(key, default)
        return result
    
    def parse_range(self, range_str: str) -> Optional[Tuple[int, int]]:
        """
        Parse a range string like "4-15" into tuple (4, 15).
        
        Args:
            range_str: Range string (e.g., "4-15" or "none")
            
        Returns:
            Tuple (start, end) or None if range is "none"
        """
        range_str = range_str.strip()
        
        if range_str.lower() == 'none':
            return None
        
        if '-' in range_str:
            parts = range_str.split('-')
            if len(parts) == 2:
                try:
                    if int(parts[0].strip()) > int(parts[1].strip()):
                        self.errors.append(f"Invalid range: start {parts[0]} is greater than end {parts[1]}")
                        return None
                    return (int(parts[0].strip()), int(parts[1].strip()))
                except ValueError:
                    self.errors.append(f"Invalid range format: {range_str}")
                    return None
                
                
        
        self.errors.append(f"Invalid range format: {range_str}")
        return None
    
    def get_atom_range_a(self) -> Optional[Tuple[int, int]]:
        """Get Atom_number_range_A as tuple."""
        val = self.config.get('Atom_number_range_A')
        return self.parse_range(val) if val else None
    
    def get_atom_range_b(self) -> Optional[Tuple[int, int]]:
        """Get Atom_number_range_B as tuple."""
        val = self.config.get('Atom_number_range_B')
        return self.parse_range(val) if val else None
    
    def get_core_mo_range(self) -> Optional[Tuple[int, int]]:
        """Get core_MO_range as tuple."""
        val = self.config.get('core_MO_range')
        return self.parse_range(val) if val else None
    
    def get_exc_state_range(self) -> Optional[Tuple[int, int]]:
        """Get exc_state_range as tuple or None if 'none'."""
        val = self.config.get('exc_state_range')
        return self.parse_range(val) if val else None
    
    def get_soc_option(self) -> int:
        """Get soc_option as integer (0 or 1)."""
        val = self.config.get('soc_option', '0').strip()
        try:
            soc = int(val)
            if soc not in (0, 1):
                self.warnings.append(f"soc_option should be 0 or 1, got {soc}. Using 0.")
                return 0
            return soc
        except ValueError:
            self.errors.append(f"soc_option must be an integer, got: {val}")
            return 0
    
    def get_orca_output(self) -> str:
        """Get orca_output filename."""
        return self.config.get('orca_output', '').strip()
    
    def get_input_path(self) -> Optional[str]:
        """Get input_path, converting to absolute if relative."""
        path = self.config.get('input_path')
        if path:
            path = path.strip()
            if path and not os.path.isabs(path):
                path = os.path.abspath(path)
        return path if path else None
    
    def get_output_path(self) -> Optional[str]:
        """Get output_path, converting to absolute if relative."""
        path = self.config.get('output_path')
        if path:
            path = path.strip()
            if path and not os.path.isabs(path):
                path = os.path.abspath(path)
        return path if path else None

    def to_migrator_args(self) -> str:
        """
        Generate command-line arguments for migrator.sh before running manager.sh
        
        Returns:
            String of arguments for migrator.sh
        """
        out_file = self.get_orca_output()
        ext_file = self.config.get('external_MO_file', out_file).strip()
        input_path = self.get_input_path()
        output_path = self.get_output_path()
        
        args = [
            out_file, ext_file
        ]
        
        if input_path:
            args.append(input_path)
        if output_path:
            args.append(output_path)
        
        return ' '.join(args)
    
    def to_manager_args(self) -> str:
        """
        Generate command-line arguments for manager.sh in the original format.
        
        Returns:
            String of arguments for manager.sh
        """
        a_ini, a_fin = self.get_atom_range_a() or (None, None)
        b_ini, b_fin = self.get_atom_range_b() or (None, None)
        mo_ini, mo_fin = self.get_core_mo_range() or (None, None)
        exc_range = self.config.get('exc_state_range', '').strip()
        soc = self.get_soc_option()
        out_file = self.get_orca_output()
        spectra = self.config.get('spectra_option', '0').strip()
        atm_core = self.config.get('atm_core', 'C').strip()
        wavef = self.config.get('wave_f_type', 's').strip()
        ext_file = self.config.get('external_MO_file', out_file).strip()
        input_path = self.get_input_path()
        output_path = self.get_output_path()
        
        args = [
            str(a_ini), str(a_fin), str(b_ini), str(b_fin),
            str(mo_ini), str(mo_fin), str(soc), out_file,
            exc_range, spectra, atm_core, wavef, ext_file
        ]
        
        if input_path:
            args.append(input_path)
        if output_path:
            args.append(output_path)
        
        return ' '.join(args)
