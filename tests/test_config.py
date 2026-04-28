"""
Unit tests for configuration validation module.
"""

import pytest
import os
import sys
from pathlib import Path

# Add package to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from xas_qmol_parser.config import ConfigManager
from xas_qmol_parser.validator import ConfigValidator


class TestConfigManager:
    """Test ConfigManager functionality."""
    
    def test_parse_range_valid(self):
        """Test parsing valid range strings."""
        config = ConfigManager()
        
        assert config.parse_range("4-15") == (4, 15)
        assert config.parse_range("0-46") == (0, 46)
        assert config.parse_range("1-1") == (1, 1)
    
    def test_parse_range_none(self):
        """Test parsing 'none' keyword."""
        config = ConfigManager()
        
        assert config.parse_range("none") is None
        assert config.parse_range("NONE") is None
    
    def test_parse_range_invalid(self):
        """Test parsing invalid range strings."""
        config = ConfigManager()
        
        assert config.parse_range("abc-def") is None
        assert config.parse_range("invalid") is None
        assert len(config.errors) > 0
    
    def test_parse_range_spaces(self):
        """Test parsing range strings with spaces."""
        config = ConfigManager()
        
        # Should handle spaces
        result = config.parse_range(" 4 - 15 ")
        assert result == (4, 15)
    
    def test_load_missing_file(self):
        """Test loading missing config file."""
        config = ConfigManager("nonexistent.info")
        
        assert not config.load()
        assert len(config.errors) > 0
        assert "not found" in config.errors[0]
    
    def test_get_method(self):
        """Test get method for retrieving config values."""
        config = ConfigManager()
        config.config = {
            'test_key': 'test_value',
            'another': 'value'
        }
        
        assert config.get('test_key') == 'test_value'
        assert config.get('nonexistent') is None
        assert config.get('nonexistent', 'default') == 'default'


class TestConfigValidator:
    """Test ConfigValidator functionality."""
    
    def setup_method(self):
        """Setup for each test."""
        self.config = ConfigManager()
        self.config.config = {
            'Atom_number_range_A': '0-46',
            'Atom_number_range_B': '0-46',
            'core_MO_range': '7-24',
            'exc_state_range': '1-26',
            'soc_option': '0',
            'orca_output': 'test.out',
        }
    
    def test_validate_all_mandatory_present(self):
        """Test validation when all mandatory fields are present."""
        validator = ConfigValidator(self.config)
        # Should not add errors for missing mandatory fields
        validator._validate_mandatory_flags()
        
        # These errors are only in errors list, not from validation
        assert len(validator.errors) == 0
    
    def test_validate_all_mandatory_missing(self):
        """Test validation when mandatory fields are missing."""
        config = ConfigManager()
        config.config = {'some_field': 'value'}
        
        validator = ConfigValidator(config)
        validator._validate_mandatory_flags()
        
        assert len(validator.errors) > 0
    
    def test_validate_invalid_ranges(self):
        """Test validation of invalid ranges."""
        self.config.config['Atom_number_range_A'] = '-5-10'
        self.config.config['core_MO_range'] = '100-50'
        
        validator = ConfigValidator(self.config)
        validator.validate_all()
        
        # Should have errors for negative and inverted ranges
        assert any('negative' in e.lower() for e in validator.errors)
        assert any('greater than' in e.lower() for e in validator.errors)
    
    def test_validate_soc_option_valid(self):
        """Test validation of valid soc_option values."""
        validator = ConfigValidator(self.config)
        
        # soc_option should be 0 or 1
        assert self.config.get_soc_option() == 0
        
        self.config.config['soc_option'] = '1'
        assert self.config.get_soc_option() == 1
    
    def test_validate_soc_option_invalid(self):
        """Test validation of invalid soc_option values."""
        self.config.config['soc_option'] = '2'
        
        validator = ConfigValidator(self.config)
        validator._validate_soc_option()
        
        assert len(validator.errors) > 0
    
    def test_validate_atm_core_warning(self):
        """Test validation produces warning for non-standard atom core."""
        self.config.config['atm_core'] = 'X'
        
        validator = ConfigValidator(self.config)
        validator._validate_atom_core()
        
        assert len(validator.warnings) > 0


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
