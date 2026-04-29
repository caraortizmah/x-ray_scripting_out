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


def run_xasqm_parsersetup() -> int:
    """
    Entry point for 'xasqm-parser-setup' console script.
    Runs setup.sh followed by check_environment.sh.
    """
    try:
        print("=" * 60)
        print("Setting up x-ray-quantumol-parser environment...")
        print("=" * 60)
        
        # Run setup.sh
        setup_script = _get_script_path("setup.sh", "bin")
        print("\n[1/2] Running setup.sh...")
        result = subprocess.run(["bash", str(setup_script)], check=False)
        if result.returncode != 0:
            print(f"Warning: setup.sh exited with code {result.returncode}")
        
        # Run check_environment.sh
        check_script = _get_script_path("check_environment.sh", "bin")
        print("\n[2/2] Running check_environment.sh...")
        result = subprocess.run(["bash", str(check_script)], check=False)
        
        print("\n" + "=" * 60)
        print("Setup complete!")
        print("=" * 60)
        
        return result.returncode
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1


def run_xasqm_parsertest() -> int:
    """
    Entry point for 'xasqm-parser-test' console script.
    Runs automated tests using tester.sh for both AB_4.0A and AB_5.0A models.
    """
    try:
        print("=" * 60)
        print("Running x-ray-quantumol-parser test suite...")
        print("=" * 60)
        
        tester_script = _get_script_path("tester.sh", "tests")
        
        # Test 1: AB_4.0A (without SOC)
        print("\n[1/2] Testing AB_4.0A model (no SOC)...")
        cmd1 = ["bash", str(tester_script), "ab40_test", "AB_4.0A.out", "config.info_examplenosoc"]
        result1 = subprocess.run(cmd1, check=False)
        
        # Test 2: AB_5.0A (with SOC)
        print("\n[2/2] Testing AB_5.0A model (with SOC)...")
        cmd2 = ["bash", str(tester_script), "ab50_test", "AB_5.0A.out", "config.info_examplesoc"]
        result2 = subprocess.run(cmd2, check=False)
        
        print("\n" + "=" * 60)
        if result1.returncode == 0 and result2.returncode == 0:
            print("All tests passed!")
        else:
            print("Some tests failed. Please review the output above.")
        print("=" * 60)
        
        # Return non-zero if any test failed
        return max(result1.returncode, result2.returncode)
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    # For testing CLI entry points
    if len(sys.argv) > 1:
        command = sys.argv[1]
        if command == "parser":
            sys.exit(run_xasqm_parser())
        elif command == "setup":
            sys.exit(run_xasqm_parsersetup())
        elif command == "test":
            sys.exit(run_xasqm_parsertest())
    
    print("Usage: xasqm-parser|xasqm-parser-setup|xasqm-parser-test [args]")
    sys.exit(1)
