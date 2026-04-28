"""
Configuration and file validation for the X-ray spectroscopy pipeline.
"""

import os
from pathlib import Path
from typing import List, Tuple, Optional
from .config import ConfigManager


class ConfigValidator:
    """
    Validates configuration parameters and ORCA input files.
    """
    
    def __init__(self, config: ConfigManager):
        """
        Initialize validator with a ConfigManager instance.
        
        Args:
            config: ConfigManager instance with loaded configuration
        """
        self.config = config
        self.errors: List[str] = []
        self.warnings: List[str] = []
    
    def validate_all(self) -> bool:
        """
        Run all validation checks.
        
        Returns:
            bool: True if all validations pass, False otherwise
        """
        # Add config's errors and warnings
        self.errors.extend(self.config.errors)
        self.warnings.extend(self.config.warnings)
        
        # Run validation checks
        self._validate_mandatory_flags()
        self._validate_ranges()
        self._validate_files()
        self._validate_soc_option()
        self._validate_atom_core()
        self._validate_wave_f_type()
        
        return len(self.errors) == 0
    
    def _validate_mandatory_flags(self) -> None:
        """Validate that all mandatory flags are present."""
        mandatory = self.config.MANDATORY_FLAGS.keys()
        for flag in mandatory:
            if flag not in self.config.config:
                self.errors.append(f"Mandatory flag missing: {flag}")
    
    def _validate_ranges(self) -> None:
        """Validate that range parameters are valid."""
        ranges_to_check = [
            ('Atom_number_range_A', self.config.get_atom_range_a()),
            ('Atom_number_range_B', self.config.get_atom_range_b()),
            ('core_MO_range', self.config.get_core_mo_range()),
        ]
        
        for name, range_tuple in ranges_to_check:
            if range_tuple is None:
                continue
            
            start, end = range_tuple
            if start < 0 or end < 0:
                self.errors.append(f"{name}: negative numbers not allowed")
            elif start > end:
                self.errors.append(f"{name}: start ({start}) cannot be greater than end ({end})")
    
    def _validate_files(self) -> None:
        """Validate that required input files exist in the specified input_path."""
        orca_file = self.config.get_orca_output()
        
        if not orca_file:
            self.errors.append("orca_output cannot be empty")
            return
        
        # Get input path
        input_path = self.config.get_input_path()
        
        # If input_path is specified, files MUST exist there (strict check)
        if input_path:
            # Check ORCA output file
            full_path_orca = os.path.join(input_path, orca_file.strip())
            if not os.path.isfile(full_path_orca):
                self.errors.append(
                    f"ORCA output file not found in input_path:\n"
                    f"  Expected: {full_path_orca}\n"
                    f"  Check input_path in config.info or verify file exists"
                )
            
            # Check external MO file if different from orca_output
            ext_file = self.config.config.get('external_MO_file', '').strip()
            if ext_file and ext_file != orca_file.strip():
                full_path_ext = os.path.join(input_path, ext_file)
                if not os.path.isfile(full_path_ext):
                    self.errors.append(
                        f"External MO file not found in input_path:\n"
                        f"  Expected: {full_path_ext}\n"
                        f"  Check external_MO_file in config.info or verify file exists"
                    )
        else:
            # No input_path specified - check current directory (warning only)
            if not os.path.isfile(orca_file.strip()):
                self.warnings.append(
                    f"ORCA output file not found in current directory: {orca_file}\n"
                    f"  Set input_path in config.info or place files in current directory"
                )
            
            # Check external MO file
            ext_file = self.config.config.get('external_MO_file', '').strip()
            if ext_file and ext_file != orca_file.strip():
                if not os.path.isfile(ext_file):
                    self.warnings.append(
                        f"External MO file not found in current directory: {ext_file}\n"
                        f"  Set input_path in config.info or place files in current directory"
                    )
    
    def _validate_soc_option(self) -> None:
        """Validate soc_option parameter."""
        soc = self.config.get_soc_option()
        if soc not in (0, 1):
            self.errors.append(f"soc_option must be 0 or 1, got: {soc}")
    
    def _validate_atom_core(self) -> None:
        """Validate atm_core parameter."""
        atm_core = self.config.config.get('atm_core', 'C').strip()
        valid_atoms = ['C', 'N', 'O', 'S', 'P']
        if atm_core not in valid_atoms:
            self.warnings.append(
                f"atm_core '{atm_core}' is not a standard choice. "
                f"Common choices: {', '.join(valid_atoms)}"
            )
    
    def _validate_wave_f_type(self) -> None:
        """Validate wave_f_type parameter."""
        wavef = self.config.config.get('wave_f_type', 's').strip()
        valid_types = ['s', 'p', 'd']
        if wavef not in valid_types:
            self.warnings.append(
                f"wave_f_type '{wavef}' is not standard. "
                f"Common choices: {', '.join(valid_types)}"
            )
    
    def validate_output_path(self, output_path: Optional[str] = None) -> bool:
        """
        Validate that output path is writable.
        
        Args:
            output_path: Override output path (if None, uses config)
            
        Returns:
            bool: True if writable, False otherwise
        """
        path = output_path or self.config.get_output_path()
        
        if not path:
            path = os.getcwd()
        
        # Create parent directory if needed
        if not os.path.exists(path):
            try:
                os.makedirs(path, exist_ok=True)
            except Exception as e:
                self.errors.append(f"Cannot create output directory {path}: {str(e)}")
                return False
        
        if not os.access(path, os.W_OK):
            self.errors.append(f"Output path is not writable: {path}")
            return False
        
        return True
    
    def get_summary(self) -> str:
        """
        Get a summary of validation results.
        
        Returns:
            str: Formatted summary
        """
        lines = []
        
        if self.errors:
            lines.append("x VALIDATION ERRORS:")
            for error in self.errors:
                lines.append(f"   - {error}")
        else:
            lines.append("+ No errors found")
        
        if self.warnings:
            lines.append("\n! WARNINGS:")
            for warning in self.warnings:
                lines.append(f"   - {warning}")
        
        return '\n'.join(lines)
