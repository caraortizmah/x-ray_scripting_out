# Installation Guide for x-ray-quantumol-parser

In case installation is not intended:

### Direct Script Execution (without installation or Python)

Read [quickstart_old.md](quickstart_old.md) to understand how the Pipeline works only in shell.

From the repository root:

```bash
./src/manager.sh [options]
./src/helper_man.sh [options]
```

### Direct Script Execution using Python (without installation)

Read [quickstart.md](quickstart.md) to understand how the Pipeline works.

```bash
python3 bin/helper_man.py [options]
```

## Quick Install

### From PyPI, mainly for users (not released yet)

```bash
pip install x-ray-quantumol-parser
```

Get to know the Pipeline: 
Read [quickstart.md](quickstart.md) to understand how the Pipeline works.
Read [quickstart_old.md](quickstart_old.md) to understand how the Pipeline works only in shell.


## From repo, mainly for developers (as a package)

For development and testing:

### 1. Clone repo

```bash
git clone https://github.com/caraortizmah/x-ray_scripting_out.git
cd x-ray_scripting_out
```

### 2. Create virtual environment (recommended)

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install package in development mode

```bash
pip install -e .
```

### 4. Install development dependencies

```bash
pip install -e ".[dev]"
```

This installs:
- pytest and pytest-cov (testing)
- shellcheck-py (shell script linting)
- pandas


##  Verify installation

### 1. Check package installation

```bash
python3 -c "import xas_qmol_parser; print(xas_qmol_parser.__version__)"
```

Expected output: `3.0.2`

### 2. Verify Command Availability

```bash
which xasqm-parser
which xasqm-parser-setup
which xasqm-parser-test
```

## Setup and check the Pipeline

After installation, you can check it:

```bash
# For help
xasqm-parser --help
```
To setup and check installation:

```bash
# Setup
xasqm-parser-setup
```

**xasqm-parser-setup does:**
1. Runs `bin/setup.sh`
2. Runs `bin/check_environment.sh`

## Automated test to check parser data

```bash
# Run examples for tests
xasqm-parser-test
```

**xasqm-parser-test does:**
1. Tests AB_4.0A model (no SOC) - `tests/tester.sh ab40_test AB_4.0A.out config.info_examplenosoc`
2. Tests AB_5.0A model (with SOC) - `tests/tester.sh ab50_test AB_5.0A.out config.info_examplesoc`

Please READ [goodtoknow_config.info.md](goodtoknow_config.info.md) to understand the config.info file required (and orca output).

## Regression test: examples (final pipeline verification)

Run tests without coverage (faster):
```bash
pytest tests/ -v
```

Run tests with coverage (requires pytest-cov, added when installation is done):
```bash
pytest tests/ -v --cov=xas_qmol_parser --cov-report=html
```

Now you can run by your own

## Run Pipeline

```bash
xasqm-parser
```

**xasqm-parser does:**
1. Runs `bin/helper_man.py`

## Documentation for Pipeline usage

Read 
- 1. [quickstart.md](quickstart.md)
- 2. [quickstart_old.md](quickstart_old.md)
- 3. [examplesrun.md](examplesrun.md) for pipeline usage
- 4. [goodtoknow_config.info.md](goodtoknow_config.info.md) for the config.info


## System Requirements

- **OS**: Linux (primary support)
- **Python**: 3.8 or later
- **Shell**: Bash 4.0+
- **ORCA**: Output files from ORCA 4.0 or 5.0
- **Tools**: Standard Unix utilities (grep, awk, sed, etc.)

## Troubleshooting

### Command Not Found

If `xasqm-parser`, `xasqm-parser-setup` or `xasqm-parser-test` commands are not found after installation:

```bash
# Verify installation path
pip show x-ray-quantumol-parser

# Reinstall in editable mode
pip install --force-reinstall -e .
```

### Python Import Errors

```bash
# Verify package is installed
python3 -m pip list | grep x-ray-quantumol-parser

# Check Python path
python3 -c "import sys; print('\n'.join(sys.path))"
```

### Shell Script Permission Errors

If shell scripts aren't executable:

```bash
chmod +x src/*.sh
chmod +x bin/*.sh
```

## Uninstallation

To remove the package (named x-ray-quantumol-parser):

```bash
pip uninstall x-ray-quantumol-parser
```

### Missing Dependencies when Pipeline is used with no installation

Install specific optional dependencies:

```bash
# For testing
pip install pytest pytest-cov

# For code quality
pip install shellcheck-py

# For building/publishing
pip install build twine
```

## Next Steps: Documenation for evelopers

- Read [quickstart.md](quickstart.md), [examplesrun.md](examplesrun.md) for pipeline usage
- Check [architecture.md](architecture.md) for system design
- Further reading [data_processing_tests.md](data_processing_tests.md) and [regression_testing_examples.md](regression_testing_examples.md)
- See [contributing.md](contributing.md) for development guidelines


Please READ the rest of the documentation in `docs/` such as:
1. [examplesrun.md](examplesrun.md) to understand depper how to run
2. [data_processing_tests.md](data_processing_tests.md) to understand depper how to run tests and shell scripts
3. [regression_testing_examples.md](regression_testing_examples.md) to do specific tests and not all of them
4. Check [architecture.md](architecture.md) for system design
5. See [contributing.md](contributing.md) for development guidelines

In the future contributing.md and publishing.md

Enjoy! :)