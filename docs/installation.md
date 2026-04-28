# Installation Guide for x-ray-quantumol-parser

## Quick Install

### From PyPI (when published)

```bash
pip install x-ray-quantumol-parser
```

Then run:
```bash
manager [options]
# or
overall [options]
```

## Development Installation

For development and testing:

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/x-ray_scripting_out.git
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

After installation, you can run:

```bash
# Run manager script
manager --help

# Run overall script  
overall --help
```

### Direct Script Execution (Without Installation)

From the repository root:

```bash
./src/manager.sh [options]
./src/overall.sh [options]
```

Or using Python:

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

Expected output: `3.0.0`

### 2. Verify Command Availability

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

### Missing Dependencies

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

To remove the package:

```bash
pip uninstall x-ray-quantumol-parser
```

Or in development mode:

```bash
pip uninstall -e .
```

## Next Steps

- Read [quickstart.md](quickstart.md) for pipeline usage
- Check [architecture.md](architecture.md) for system design
- See [contributing.md](contributing.md) for development guidelines
