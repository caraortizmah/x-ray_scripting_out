"""
Command-line interface entry points for the x-ray spectroscopy pipeline.

These functions serve as entry points for installed console scripts.
"""

import sys
import os
import subprocess
from pathlib import Path


def _get_script_path(script_name: str, subdir: str = "bin") -> Path:
    """
    Get the absolute path to a shell script or Python script.
    
    Args:
        script_name: Name of the script (e.g., 'helper_man.py', 'setup.sh')
        subdir: Subdirectory to search ('bin', 'src', 'tests')
        
    Returns:
        Path to the script
        
    Raises:
        FileNotFoundError: If script is not found
    """
    # Try installation location first
    package_dir = Path(__file__).parent.parent
    script_path = package_dir / subdir / script_name
    
    if script_path.exists():
        return script_path
    
    # Fallback to current directory
    cwd_path = Path.cwd() / subdir / script_name
    if cwd_path.exists():
        return cwd_path
    
    raise FileNotFoundError(f"Script not found: {subdir}/{script_name}")


def run_xasqm_parser() -> int:
    """
    Entry point for 'xasqm-parser' console script.
    Runs bin/helper_man.py with command-line arguments.
    Provides --help to display usage information.
    """
    try:
        # Check for --help flag
        if len(sys.argv) > 1 and sys.argv[1] in ('--help', '-h', 'help'):
            help_msg = """
xas-qmol-parser: X-ray Absorption Spectroscopy Quantum Molecular Parser

USAGE:
    xasqm-parser [options]

This command calls bin/helper_man.py to run the X-ray spectroscopy pipeline.

For detailed information on usage, examples, and configuration, please see:
    - README.md: Project overview and quick start
    - docs/quickstart.md: Step-by-step tutorial
    - docs/architecture.md: System design and data flow
    - docs/installation.md: Installation instructions

RELATED COMMANDS:
    xasqm-parser-setup     Setup environment and dependencies
    xasqm-parser-test      Run automated tests

"""
            print(help_msg)
            return 0
        
        script = _get_script_path("helper_man.py", "bin")
        result = subprocess.run([sys.executable, str(script)] + sys.argv[1:], check=False)
        return result.returncode
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1


def run_overall() -> int: #test (main one is helper_man.sh)
    """
    Entry point for 'overall' console script.
    Runs src/overall.sh with command-line arguments.
    """
    try:
        script = _get_script_path("overall.sh")
        result = subprocess.run([str(script)] + sys.argv[1:], check=False)
        return result.returncode
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    # For testing CLI entry points
    if len(sys.argv) > 1:
        command = sys.argv[1]
        if command == "manager":
            sys.exit(run_manager())
        elif command == "overall":
            sys.exit(run_overall())
    
    print("Usage: manager|overall [args]")
    sys.exit(1)
