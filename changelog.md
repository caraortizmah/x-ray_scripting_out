# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-24

### Added - Phase 1: Foundation

#### Project Structure
- New directory organization: `src/`, `tests/`, `docs/`, `bin/`, `xray_scripting/`
- Python package `xray_scripting` for core functionality
- `src/` contains the steps (.sh files)
- `tests/` will implement a run test
- `bin/` will implement the setup and the 'helper_man' in python

#### Configuration Management
- `ConfigManager` class for parsing and managing config.info
- Support for mandatory and optional flags
- Range parsing utility ("4-15" format)
- Type-safe parameter access methods
- Configuration-to-command-line conversion

#### Input Validation
- `ConfigValidator` class with comprehensive checks
- Validates mandatory flags presence
- Validates range parameters (non-negative, start <= end)
- Validates file existence and paths
- Parameter value range validation (soc_option, atm_core, wave_f_type)
- Output path writability checks
- Error and warning categorization

#### Logging System
- `setup_logger()` function for configurable logging
- Colored console output (ERROR=red, WARNING=yellow, INFO=green)
- Timestamped file logging with debug level
- Separate console (INFO) and file (DEBUG) log levels
- Execution metadata logging utilities
- Log file organization in output directory

#### Scripts & Tools
- `bin/setup.sh`: Project setup script
- `bin/check_environment.sh`: Environment verification
- `bin/helper_man.py`: Enhanced Python-based helper (validates + logs)
- Updated original `helper_man.sh` (preserved for backward compatibility)

#### Documentation
- `docs/ARCHITECTURE.md`: System design and data flow
- `docs/QUICKSTART.md`: Getting started guide
- `docs/CONTRIBUTING.md`: Development guidelines
- Python docstrings for all modules

#### Testing
- Unit tests for ConfigManager
- Unit tests for ConfigValidator
- Pytest configuration ready
- Test fixtures for common scenarios

#### Quality Assurance
- Enhanced `.gitignore` with Python-specific entries
- `requirements.txt` with dependencies
- `CHANGELOG.md` for version tracking

#### Examples
- Example configuration file with comments
- Sample configurations for different use cases (C K-edge, O K-edge, S L-edge)

### Changed
- Project now uses Python for validation and logging (backward compatible)
- Improved error messages and user feedback
- Better code organization with Python modules

### Fixed
- Configuration parsing robustness
- Error handling in parameter validation

### Deprecated
- Direct use of positional arguments (recommend using config.info instead)

### Technical Details

**New Dependencies**:
- Python 3.6+ (on the python + shell version)
- pytest (for testing and python 3.10+)
- Standard Unix tools: awk, grep, sed, cut, tr, sort, uniq, wc, head, tail

**Breaking Changes**: None - fully backward compatible

**Migration Guide**:
All existing workflows continue to work. New features are additive.

## [0.1.0] - Previous Release

Original shell script implementation.

---

## Roadmap

### Phase 2 (Coming Soon)
- CLI improvements with named flags (`--atom-range-a` instead of `$1`)
- Interactive configuration builder
- Help system (`-h`, `--help`)
- Config format alternatives (YAML, JSON)

### Phase 3 (Short-term)
- Parallel processing support
- Batch processing manager
- Performance profiling
- Resume/checkpointing capability

### Phase 4 (Medium-term)
- GUI application
- Data visualization
- Output format converters (JSON, HDF5)
- Plugin/extension system

### Phase 5+ (Long-term)
- REST API server
- Database backend
- Advanced analytics
- Publication-ready visualizations

---

## Installation & Usage

### Quick Start
```bash
./bin/setup.sh
./bin/check_environment.sh
./bin/helper_man.py --validate-only
./bin/helper_man.py
```

### Detailed Guide
See [docs/quickstart.md](docs/quickstart.md)

---

## Versioning

We use [Semantic Versioning](https://semver.org/):
- MAJOR: Incompatible API changes
- MINOR: New backward-compatible features
- PATCH: Bug fixes and improvements

---

## License

See LICENSE file for details.

---

## Contributors

- Carlos Ortiz-Mahecha (Project Lead)
- Community contributions welcome (see contributing.md)
