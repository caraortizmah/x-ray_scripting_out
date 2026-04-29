# Installation Guide for x-ray-quantumol-parser

## Quick Install

### From PyPI (mainly for users)

```bash
pip install x-ray-quantumol-parser
```

Then run:
```bash
manager [options]
# or
overall [options]
```

## Development Installation (as a package)

For development and testing:

### 1. Clone repo

```bash
git clone https://github.com/caraortizmah/x-ray_scripting_out.git
cd x-ray_scripting_out
```

### 2. Create Virtual Environment (Recommended)

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Package in Development Mode

```bash
pip install -e .
```

### 4. Install Development Dependencies

```bash
pip install -e ".[dev]"
```

This installs:
- pytest and pytest-cov (testing)
- shellcheck-py (shell script linting)

## Running the Pipeline

### Using Installed Commands

After installation, you can check:

```bash
# For help
xasqm-parser --help
```
To do before running:

```bash
# Setup
xasqm-parser-setup
# Test
xasqm-parser-test
# Check test
pytest tests/ -v
```
Before using `xasqm-parser`
```bash
# xasqm-parser (alone) calls /bin/helper_man.py
xasqm-parser
```
Please READ [quickstart.md](quickstart.md) to understand how the Pipeline runs.

# Run overall script  it should call helper_manager (not working yet)
#overall --help
```
xasqm_parser will call `bin/helper_man.py`

1. Please READ [quickstart.md](quickstart.md) to understand how the Pipeline runs.
2. Then READ [goodtoknow_config.info.md] to understand the config.info file required (and orca output).

Then now you can run:
```bash
# Run xas_quantumol_parser package
xasqm_parser 
```

### Direct Script Execution (Without Installation or Python)

Read [quickstart_old.md](quickstart_old.md) to understand how the Pipeline works only in shell.

From the repository root:

```bash
./src/manager.sh [options]
./src/helper_man.sh [options]
```

### Direct Script Execution using Python (Without Installation)

Read [quickstart.md](quickstart.md) to understand how the Pipeline works.

```bash
python3 bin/helper_man.py [options]
```

## System Requirements

- **OS**: Linux (primary support)
- **Python**: 3.8 or later
- **Shell**: Bash 4.0+
- **ORCA**: Output files from ORCA 4.0 or 5.0
- **Tools**: Standard Unix utilities (grep, awk, sed, etc.)

## Verifying Installation

### 1. Check Package Installation

```bash
python3 -c "import xas_qmol_parser; print(xas_qmol_parser.__version__)"
```

Expected output: `3.0.2`

### 2. Verify Command Availability
#### to be only /bin/helper_man.py
```bash
which manager
which overall
```

### 3. Run Tests

```bash
pytest tests/ -v
```

## Troubleshooting

### Command Not Found

If `manager` or `overall` commands are not found after installation:

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

## Uninstallation

To remove the package (named x-ray-quantumol-parser):

```bash
pip uninstall x-ray-quantumol-parser
```

## Next Steps

- Read [quickstart.md](quickstart.md), [examplesrun.md](examplesrun.md) for pipeline usage
- Check [architecture.md](architecture.md) for system design
- Further reading [data_processing_tests.md](data_processing_tests.md) and [regression_testing_examples.md](regression_testing_examples.md)
- See [contributing.md](contributing.md) for development guidelines
