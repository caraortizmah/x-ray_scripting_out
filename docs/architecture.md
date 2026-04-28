# X-ray Spectroscopy Pipeline - Architecture & Development

## Project Structure

```
x-ray_scripting_out/
├── bin/                      # Entry point scripts
│   ├── setup.sh             # Project setup script
│   ├── check_environment.sh # Environment verification
│   └── helper_man.py        # Enhanced helper script (Python)
│
├── src/                      # Shell scripts (pipeline steps)
│   ├── manager.sh
│   ├── helper_man.sh (original)
│   └── step*.sh
│
├── xray_scripting/          # Python package (new)
│   ├── __init__.py
│   ├── config.py            # Configuration management
│   ├── validator.py         # Input validation
│   └── logger.py            # Logging system
│
├── tests/                   # Unit tests
│   ├── fixtures/
│   │   ├── reference_data/  # Toy models reference data
│   │   │    ├── nosoc/      # AB_4.0A model, FY (6 csv files)
│   │   │    ├── soc/        # AB_5.0A model, MW (10 csv files)
│   │   └── README.md
│   ├── tester.sh            # Tester for automate running
│   ├── conftest.py          # Tests for config module
│   ├── test_conf.py         # Tests for config validation module
│   └── test_data_processing.py    # Tests for regression data
│
├── docs/                    # Documentation
│   ├── architecture.md      # This file
│   ├── contributing.md      # Contribution guidelines
│   ├── data_processing_tests.md  # Data test guide
│   ├── examplesrun.md       # Guidelines of the ORCA files and run
│   ├── goodtoknow_config.info.md # config.info documentation
│   ├── quickstart_old.md    # How to run (shell version)
│   ├── quickstart.md    # How to run (+pythonshell version)
│   └── regression_testing_examples.md # Regression test guideline
│
├── examples/                # Example configurations
│   ├── config.info_examplenosoc     # Example config file nosoc case
│   ├── config.info_examplesoc       # Example config file soc case
│   ├── AB_4.0A.out          # Example ORCA output file nosoc case
│   ├── AB_5.0A.out          # Example ORCA output file soc case
│   └── examples_overview.md
│
├── input/                   # ORCA input files directory
└── output/                  # Pipeline output directory

```

## Data Flow

```
config.info
    ↓
ConfigManager (parse & read)
    ↓
ConfigValidator (validate)
    ↓
Logger (setup logging)
    ↓
manager.sh (execute)
    ↓
Output/ (CSV matrices)
```

## Configuration Management

### ConfigManager (`xray_scripting/config.py`)

**Purpose**: Parse and manage configuration files

**Key Methods**:
- `load()`: Load config.info file
- `parse_range()`: Parse "4-15" format ranges
- `get_*()`：Get specific parameters
- `to_manager_args()`: Generate manager.sh arguments

**Example Usage**:
```python
from xray_scripting import ConfigManager

config = ConfigManager("config.info")
if config.load():
    a_range = config.get_atom_range_a()  # Returns (0, 46)
    soc = config.get_soc_option()        # Returns 0 or 1
```

## Validation System

### ConfigValidator (`xray_scripting/validator.py`)

**Purpose**: Validate configuration and input files

**Checks Performed**:
1. Mandatory flags presence
2. Range validity (non-negative, start <= end)
3. File existence (ORCA output)
4. Parameter value ranges (soc_option, atm_core, wave_f_type)
5. Output path writability

**Example Usage**:
```python
from xray_scripting import ConfigManager, ConfigValidator

config = ConfigManager("config.info")
config.load()

validator = ConfigValidator(config)
if validator.validate_all():
    print("Configuration is valid")
else:
    print(validator.get_summary())
```

## Logging System

### Setup Logger (`xray_scripting/logger.py`)

**Features**:
- Colored console output
- Timestamped file logs
- Separate levels for console (INFO) and file (DEBUG)
- Execution metadata logging

**Example Usage**:
```python
from xray_scripting import setup_logger

logger = setup_logger(
    name="my_script",
    log_file="output/my_run.log",
    verbose=True
)

logger.info("Pipeline started")
logger.debug("Detailed information")
logger.error("An error occurred")
```

## Helper Script Usage

### Old Method (Shell):
```bash
./helper_man.sh
```

### New Method (Python):
```bash
# Validate configuration only
./bin/helper_man.py --validate-only

# Dry run (show command without executing)
./bin/helper_man.py --dry-run

# Verbose mode (debug logging)
./bin/helper_man.py --verbose

# Normal execution
./bin/helper_man.py
```

## Setup & Installation

### Initial Setup:
```bash
# Make scripts executable and setup directories
./bin/setup.sh

# Verify environment
./bin/check_environment.sh

# Validate configuration
./bin/helper_man.py --validate-only

# Run pipeline
./bin/helper_man.py
```

## Testing

### Run Tests:
```bash
# Run all tests
pytest tests/

# Run specific test file
pytest tests/test_config.py

# Verbose output
pytest tests/ -v

# With coverage
pytest tests/ --cov=xray_scripting
```

## Adding New Features

### Adding Validation Rules:

1. Add check method to `ConfigValidator` class
2. Call method from `validate_all()`
3. Add corresponding test in `tests/test_validator.py`

**Example**:
```python
def _validate_custom_field(self) -> None:
    """Validate custom field."""
    value = self.config.get('custom_field')
    if not value:
        self.errors.append("custom_field is required")
```

### Adding Configuration Parameters:

1. Add to MANDATORY_FLAGS or OPTIONAL_FLAGS dict in ConfigManager
2. Create getter method if needed
3. Add validation in ConfigValidator if needed
4. Update tests

## Error Handling

### Validation Error Levels:

- **Errors**: Block execution (return False from validate_all)
- **Warnings**: Non-blocking but logged (execution continues)

### Example Error vs Warning:

```python
# Error - blocks execution
if not os.path.exists(file):
    self.errors.append(f"File not found: {file}")

# Warning - allows execution to continue
if not standard_atom:
    self.warnings.append(f"Non-standard atom: {atom}")
```

## Best Practices

### For Developers:

1. **Always validate input** before processing
2. **Log important operations** at INFO level
3. **Include debugging info** at DEBUG level
4. **Use type hints** for clarity
5. **Write tests** for new functionality
6. **Document assumptions** in docstrings

### For Users:

1. Run `check_environment.sh` first
2. Use `--validate-only` before full run
3. Check log files in output/ for details
4. Use `--verbose` mode for debugging

## Troubleshooting

### Configuration Issues:

```bash
# Validate configuration with verbose output
./bin/helper_man.py --validate-only --verbose

# Check environment
./bin/check_environment.sh
```

### Script Permissions:

```bash
# Make all scripts executable
chmod +x bin/*.sh
chmod +x bin/*.py
chmod +x src/*.sh
```

### Python Import Errors:

```bash
# Ensure Python can find the package
export PYTHONPATH="${PYTHONPATH}:$(pwd)"
python3 -c "from xray_scripting import ConfigManager"
```
