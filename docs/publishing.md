# Publishing x-ray-quantumol-parser to PyPI

This guide explains how to build and publish the package to PyPI.

## Prerequisites

1. Python 3.8+ and `pip`
2. Build tools:
   ```bash
   pip install build twine
   ```
3. PyPI account (create at https://pypi.org/account/register/)
4. API token from PyPI (or TestPyPI for testing)

## Step 1: Update Version

Before publishing, update the version in:
- `pyproject.toml` (project.version)
- `xas_qmol_parser/__init__.py` (__version__)
- `changelog.md` (add new section for the release)

Example:
```toml
# pyproject.toml
version = "3.1.0"
```

```python
# xas_qmol_parser/__init__.py
__version__ = "3.1.0"
```

## Step 2: Build Distribution

```bash
python -m build
```

This creates:
- `dist/x-ray-quantumol-parser-X.Y.Z-py3-none-any.whl` (wheel)
- `dist/x-ray-quantumol-parser-X.Y.Z.tar.gz` (source distribution)

## Step 3: Validate Build

```bash
twine check dist/*
```

## Step 4: Test on TestPyPI (Recommended)

```bash
# Create ~/.pypirc with your credentials:
# [testpypi]
# repository = https://test.pypi.org/legacy/
# username = __token__
# password = pypi-AgEIcHlwaS5vcmc...

twine upload --repository testpypi dist/*
```

Then test installation:
```bash
pip install --index-url https://test.pypi.org/simple/ x-ray-quantumol-parser
```

## Step 5: Publish to PyPI

```bash
twine upload dist/*
```

You'll be prompted for your PyPI credentials (or use ~/.pypirc).

## Step 6: Verify Publication

Check https://pypi.org/project/x-ray-quantumol-parser/

Install from PyPI:
```bash
pip install x-ray-quantumol-parser
```

## Automation with GitHub Actions

The repository includes a GitHub Actions workflow (`.github/workflows/tests.yml`) that:
- Runs tests on push/PR
- Lints shell scripts
- Builds the distribution
- Validates with `twine check`

To automate publishing on release:
1. Create a new workflow `.github/workflows/publish.yml`
2. Trigger on GitHub releases
3. Build and upload to PyPI automatically

Example trigger:
```yaml
on:
  release:
    types: [published]
```

## Using Trusted Publishers (Recommended)

For automated publishing without storing secrets:
1. Configure Trusted Publishers in PyPI project settings
2. Grant GitHub Actions permission to publish
3. PyPI will verify GitHub release authenticity

See: https://docs.pypi.org/trusted-publishers/

## Troubleshooting

### "Invalid distribution"
- Run `twine check dist/*` to see detailed errors
- Common issues: missing README, malformed metadata

### "Already exists"
- Version already published; increment version number
- PyPI prevents republishing same version

### "Unauthorized"
- Check API token is valid and has upload permissions
- Verify ~/.pypirc is correctly formatted

## Removing Files from PyPI

PyPI doesn't support file deletion, but you can:
1. Upload a yanked version (marked as skipped)
2. Re-release with corrected version
3. Request removal from PyPI admins for serious issues
