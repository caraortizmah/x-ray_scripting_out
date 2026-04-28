#!/usr/bin/env python3
"""
X-ray Spectroscopy Pipeline: Configuration Helper

This script reads configuration from config.info and executes the pipeline
with proper validation, logging, and error handling.

Usage:
    ./helper_man.py [--dry-run] [--verbose] [--validate-only]
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path

# Add package to path - handle both direct execution and via symlink
script_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(script_dir)
sys.path.insert(0, project_root)

from xas_qmol_parser import ConfigManager, ConfigValidator, setup_logger
from xas_qmol_parser.logger import get_default_log_path, log_execution_info, log_completion


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="X-ray Spectroscopy Pipeline - Configuration Helper"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show command without executing"
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Enable verbose output (debug logging)"
    )
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Only validate configuration, don't execute"
    )
    parser.add_argument(
        "--config",
        default="config.info",
        help="Path to config file (default: config.info)"
    )
    
    args = parser.parse_args()
    
    # Setup logging
    log_file = get_default_log_path("output")
    logger = setup_logger(verbose=args.verbose, log_file=log_file)
    
    logger.info("X-ray Spectroscopy Pipeline: Helper Script")
    logger.info(f"Configuration file: {args.config}")
    
    # Load and validate configuration
    logger.info("Loading configuration...")
    config = ConfigManager(args.config)
    
    if not config.load():
        logger.error("Failed to load configuration")
        logger.error(f"Errors: {', '.join(config.errors)}")
        return 1
    
    logger.info("Validating configuration...")
    validator = ConfigValidator(config)
    
    if not validator.validate_all():
        logger.error("Configuration validation failed:")
        print(validator.get_summary())
        return 1
    
    if validator.warnings:
        logger.warning("Configuration has warnings:")
        for warning in validator.warnings:
            logger.warning(f"  - {warning}")
    
    logger.info("Configuration is valid")
    
    if args.validate_only:
        logger.info("Validation complete (--validate-only specified)")
        return 0
    
    # Validate output path
    output_path = config.get_output_path()
    if not validator.validate_output_path(output_path):
        logger.error("Output path validation failed:")
        print(validator.get_summary())
        return 1
    
    # Build migrator.sh command
    logger.info("Building migrator.sh command...")
    migrator_args_str = config.to_migrator_args()
    print(f"Migrating information from the following arguments: {migrator_args_str}\n")
    mig_cmd = f"./src/migrator.sh {migrator_args_str}"

    logger.debug(f"Command: {mig_cmd}")

    # Build manager.sh command
    logger.info("Building manager.sh command...")
    args_str = config.to_manager_args()
    cmd = f"{config.get_output_path()}/tmp_last_execution/manager.sh {args_str}"
    
    logger.debug(f"Command: {cmd}")
    
    if args.dry_run:
        logger.info("DRY RUN MODE - Commands not executed")
        print(f"\nWould execute migrator: {mig_cmd}\n")
        print(f"Would execute manager: {cmd}\n")
        return 0
    
    # Log execution info
    logger.info("="*70)
    logger.info("Pipeline execution started")
    logger.info("="*70)
    
    try:
        # Execute migrator.sh first to setup temp environment
        logger.info(f"Executing migrator: {mig_cmd}")
        mig_result = subprocess.run(mig_cmd, shell=True, check=False)
        
        if mig_result.returncode != 0:
            logger.error(f"Migrator failed with exit code {mig_result.returncode}")
            return 1
        
        # Execute manager.sh from temp directory
        logger.info(f"Executing manager: {cmd}")
        result = subprocess.run(cmd, shell=True, check=False)
        
        # Cleanup temp directory
        logger.info(f"Cleaning up temporary directory: {output_path}/tmp_last_execution")
        cleanup_cmd = f"rm -rf {output_path}/tmp_last_execution"
        subprocess.run(cleanup_cmd, shell=True, check=False)
        
        if result.returncode == 0:
            logger.info("Pipeline execution completed successfully")
            return 0
        else:
            logger.error(f"Pipeline execution failed with exit code {result.returncode}")
            return 1
            
    except Exception as e:
        logger.error(f"Error executing pipeline: {str(e)}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
