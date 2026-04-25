# Quick Start Guide

Run the X-ray Spectroscopy Pipeline in 5 minutes.

## Prerequisites

- Linux or macOS
- Python 3.6+
- Standard Unix tools (awk, grep, sed, etc.)

## Step 1: Clone Repository

```bash
git clone https://github.com/caraortizmah/x-ray_scripting_out.git
cd x-ray_scripting_out
```

## Step 2: Run Setup

```bash
./bin/setup.sh
```

This script will:
- Make all shell scripts executable
- Create necessary directories
- Copy scripts to proper locations
- Verify Python environment

## Step 3: Check Environment

```bash
./bin/check_environment.sh
```

This verifies:
- ✓ Python 3.6+
- ✓ Required shell commands
- ✓ Script permissions
- ✓ Directory structure
- ✓ ORCA file compatibility

## Step 4: Configure

Edit `config.info` with your parameters:

```bash
vim config.info
```

Key parameters to set:
- `Atom_number_range_A`: Core space atoms (e.g., 0-46)
- `Atom_number_range_B`: Virtual space atoms (e.g., 0-46)
- `core_MO_range`: Core MO range (e.g., 7-24)
- `exc_state_range`: Excited states to analyze (e.g., 1-26)
- `orca_output`: Your ORCA output file name
- `input_path`: Path to ORCA files
- `output_path`: Where to save results

### Common Configurations

**C K-edge (1s)**:
```
core_MO_range          = 7-24
atm_core               = C
wave_f_type            = s
```

**O K-edge (1s)**:
```
core_MO_range          = 4-6
atm_core               = O
wave_f_type            = s
```

**S L-edge (2p) with SOC**:
```
core_MO_range          = 25-28
atm_core               = S
wave_f_type            = p
soc_option             = 1
```

## Step 5: Validate & Run

```bash
# Validate configuration only
./bin/helper_man.py --validate-only

# Dry run (show what will execute)
./bin/helper_man.py --dry-run

# Run pipeline
./bin/helper_man.py
```

### Alternative: Original Shell Script

```bash
./helper_man.sh
```

## Output Files

Pipeline generates CSV matrices in `output_path`:

- `corevirt_fosc_*.csv` - Force oscillator strength matrices
- `corevirtMO_matrix*.csv` - Core-virtual coupling matrices
- `resA_MOcore.csv` - Residue A core matrices
- `resB_MOcore.csv` - Residue B core matrices

Check log file in output directory:
```bash
tail -f output/xray_pipeline_*.log
```

## Troubleshooting

### "Command not found: python3"
Install Python 3.6+:
```bash
# Ubuntu/Debian
sudo apt-get install python3

# macOS
brew install python3
```

### "config.info not found"
Copy template and customize:
```bash
cp examples/config.example.info config.info
nano config.info
```

### "ORCA output file not found"
Set correct input path in config.info:
```
input_path = /path/to/orca/files
```

### Validation errors

Get detailed error information:
```bash
./bin/helper_man.py --validate-only --verbose
```

Review your config.info and ensure:
- All mandatory flags are set
- Ranges are valid (e.g., "4-15" not "4:15")
- File paths are correct
- Output directory is writable

### Permission denied

Change permission to the folder that the repo is cloned
and try again the procedure since the beginning or, e.g.
make scripts executable:
```bash
chmod +x bin/*.sh bin/*.py src/*.sh
```

## Getting Help

1. **Check documentation**:
   - docs/ARCHITECTURE.md - System design
   - docs/CONTRIBUTING.md - Development guide

2. **Review logs**:
   ```bash
   tail -f output/xray_pipeline_*.log
   ```

3. **Run with verbose output**:
   ```bash
   ./bin/helper_man.py --verbose
   ```

## Additional information

- **Development**: See docs/CONTRIBUTING.md
- **Advanced Usage**: See docs/ARCHITECTURE.md
- **Custom Analysis**: Modify step*.sh scripts

## Running Tests

```bash
pytest tests/ -v
```

## Support

- Review README.md for detailed documentation
- Check examples/ directory for sample configs
- Submit issues on GitHub

---

**Parse quantum X-ray Absorption calculations** Run:
```bash
./bin/helper_man.py
```

Enjoy!
