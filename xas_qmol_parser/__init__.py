"""
X-ray Absorption Spectroscopy Data Processing Pipeline

A package for processing (data parser) X-ray Absorption Spectroscopy (XAS) 
output data from ORCA (4.0 and 5.0 versions) quantum chemistry software.
"""

__version__ = "3.0.1"
__author__ = "Carlos Ortiz-Mahecha"

from .config import ConfigManager
from .logger import setup_logger
from .validator import ConfigValidator

__all__ = ["ConfigManager", "setup_logger", "ConfigValidator"]
