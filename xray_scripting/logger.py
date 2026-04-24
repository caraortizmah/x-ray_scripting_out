"""
Logging configuration and utilities for the X-ray spectroscopy pipeline.
"""

import logging
import os
from datetime import datetime
from pathlib import Path
from typing import Optional


class ColoredFormatter(logging.Formatter):
    """
    Custom formatter that adds colors to log messages.
    """
    
    COLORS = {
        'DEBUG': '\033[36m',    # Cyan
        'INFO': '\033[32m',     # Green
        'WARNING': '\033[33m',  # Yellow
        'ERROR': '\033[31m',    # Red
        'CRITICAL': '\033[41m', # Red background
    }
    RESET = '\033[0m'
    
    def format(self, record):
        """Format log record with colors."""
        levelname = record.levelname
        color = self.COLORS.get(levelname, '')
        
        # Format message
        record.levelname = f"{color}{levelname}{self.RESET}"
        return super().format(record)


def setup_logger(
    name: str = "xray_pipeline",
    log_file: Optional[str] = None,
    level: int = logging.INFO,
    verbose: bool = False
) -> logging.Logger:
    """
    Setup and return a configured logger instance.
    
    Args:
        name: Logger name (default: "xray_pipeline")
        log_file: Path to log file (if None, uses default in output directory)
        level: Logging level (default: INFO)
        verbose: If True, set level to DEBUG
        
    Returns:
        logging.Logger: Configured logger instance
    """
    if verbose:
        level = logging.DEBUG
    
    logger = logging.getLogger(name)
    logger.setLevel(level)
    
    # Prevent duplicate handlers
    if logger.handlers:
        return logger
    
    # Console handler with colors
    console_handler = logging.StreamHandler()
    console_handler.setLevel(level)
    console_formatter = ColoredFormatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    console_handler.setFormatter(console_formatter)
    logger.addHandler(console_handler)
    
    # File handler
    if log_file:
        # Create log directory if needed
        log_dir = os.path.dirname(log_file)
        if log_dir and not os.path.exists(log_dir):
            os.makedirs(log_dir, exist_ok=True)
        
        file_handler = logging.FileHandler(log_file, mode='a')
        file_handler.setLevel(logging.DEBUG)  # Log everything to file
        file_formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - [%(funcName)s:%(lineno)d] - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        file_handler.setFormatter(file_formatter)
        logger.addHandler(file_handler)
        logger.info(f"Log file: {log_file}")
    
    return logger


def get_default_log_path(output_dir: Optional[str] = None) -> str:
    """
    Get default log file path.
    
    Args:
        output_dir: Output directory (if None, uses current directory)
        
    Returns:
        str: Path to log file
    """
    if not output_dir:
        output_dir = os.getcwd()
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = os.path.join(output_dir, f"xray_pipeline_{timestamp}.log")
    
    return log_file


def log_execution_info(
    logger: logging.Logger,
    config: dict,
    input_file: str,
    output_dir: str
) -> None:
    """
    Log execution information at pipeline start.
    
    Args:
        logger: Logger instance
        config: Configuration dictionary
        input_file: Input ORCA file
        output_dir: Output directory
    """
    logger.info("="*70)
    logger.info("X-ray Spectroscopy Pipeline Execution Started")
    logger.info("="*70)
    logger.info(f"Input file: {input_file}")
    logger.info(f"Output directory: {output_dir}")
    logger.info(f"Timestamp: {datetime.now().isoformat()}")
    
    if config:
        logger.debug("Configuration parameters:")
        for key, value in config.items():
            logger.debug(f"  {key}: {value}")
    
    logger.info("-"*70)


def log_step_info(
    logger: logging.Logger,
    step_name: str,
    description: str
) -> None:
    """
    Log information about a processing step.
    
    Args:
        logger: Logger instance
        step_name: Name of the step
        description: Step description
    """
    logger.info(f"Step: {step_name}")
    logger.info(f"Description: {description}")


def log_completion(
    logger: logging.Logger,
    output_files: Optional[list] = None,
    errors: Optional[list] = None
) -> None:
    """
    Log pipeline completion information.
    
    Args:
        logger: Logger instance
        output_files: List of output files generated
        errors: List of errors encountered
    """
    logger.info("="*70)
    
    if errors:
        logger.error(f"Pipeline completed with {len(errors)} error(s)")
        for error in errors:
            logger.error(f"  - {error}")
    else:
        logger.info("Pipeline completed successfully")
    
    if output_files:
        logger.info(f"Generated {len(output_files)} output file(s):")
        for fname in output_files:
            logger.info(f"  - {fname}")
    
    logger.info(f"Completion time: {datetime.now().isoformat()}")
    logger.info("="*70)
