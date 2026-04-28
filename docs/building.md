# Building x-ray-quantumol-parser

This guide explains how to build the distribution packages locally.

## Prerequisites

Install build tools:

```bash
pip install build twine wheel
```

## Building Locally

### 1. Clean Previous Builds

```bash
rm -rf build/ dist/ *.egg-info
```

### 2. Build Distribution Packages

```bash
python -m build
```

This creates two package types in `dist/`:
- **Wheel** (.whl) - Binary package, faster installation
- **Source distribution** (.tar.gz) - Contains source code

### 3. Verify Build

```bash
twine check dist/*
```

Expected output:
```
Checking distribution dist/x-ray-quantumol-parser-3.0.0-py3-none-any.whl: Passed
Checking distribution dist/x-ray-quantumol-parser-3.0.0.tar.gz: Passed
```

### 4. Extract and Inspect (Optional)

```bash
# Wheel contents
unzip -l dist/x-ray-quantumol-parser-3.0.0-py3-none-any.whl

# Source distribution
tar -tzf dist/x-ray-quantumol-parser-3.0.0.tar.gz | head -20
```

## Testing the Build

### 1. Install Locally from Wheel

```bash
pip install dist/x-ray-quantumol-parser-3.0.0-py3-none-any.whl
```

### 2. Test Commands Work

```bash
manager --help
overall --help
```

### 3. Verify Package Version

```bash
python -c "import xas_qmol_parser; print(xas_qmol_parser.__version__)"
```

### 4. Run Tests

```bash
pytest tests/ -v
```

### 5. Uninstall Test Package

```bash
pip uninstall x-ray-quantumol-parser
```

## Build Configuration

Build configuration is defined in `pyproject.toml`:

- **Project metadata**: name, version, description, license
- **Dependencies**: Python 3.8+ (no external dependencies for core)
- **Optional dependencies**: Listed in [project.optional-dependencies]
- **Entry points**: Console scripts defined in [project.scripts]
- **Package data**: Controlled by MANIFEST.in

## Environment Variables

Set before building if needed:

```bash
# Disable pre-built wheels (force source compilation)
export PIP_NO_BINARY=:all:

# Build in verbose mode
export VERBOSE=1
```

## Troubleshooting Build Issues

### "ModuleNotFoundError: No module named 'wheel'"

```bash
pip install wheel
```

### "Invalid distribution: missing required field 'Author'"

This error means pyproject.toml metadata is incomplete. Check:
- `[project]` section has all required fields
- `authors = [{name = "...", email = "..."}]` is present

### "include *.py files not matching pattern"

The MANIFEST.in file may have issues. Verify glob patterns are correct:

```bash
# List included files
tar -tzf dist/x-ray-quantumol-parser-*.tar.gz | grep -E "\.(py|sh|md)$"
```

### Build artifacts in dist/ are outdated

```bash
# Full clean
rm -rf build/ dist/ src/x_ray_quantumol_parser.egg-info
python -m build
```

## Publishing After Building

See [docs/publishing.md](publishing.md) for uploading to PyPI.

## CI/CD Builds

The repository includes GitHub Actions workflow (`.github/workflows/tests.yml`) that:
1. Runs tests on multiple Python versions
2. Builds distribution packages
3. Validates with `twine check`

Builds are automatic on:
- Push to main/develop
- Pull requests
- Manual trigger via GitHub Actions UI
