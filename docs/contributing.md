# Contributing Guide

## Getting Started

1. **Fork and Clone**:
   ```bash
   git clone https://github.com/yourusername/x-ray_scripting_out.git
   cd x-ray_scripting_out
   ```

2. **Setup Development Environment**:
   ```bash
   ./bin/setup.sh
   ./bin/check_environment.sh
   python3 -m pip install pytest pytest-cov
   ```

3. **Run Tests**:
   ```bash
   pytest tests/ -v
   ```

## Development Workflow

### 1. Create Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 2. Make Changes

**For Python modules**:
- Follow PEP 8 style guide
- Add type hints
- Include docstrings
- Add unit tests

**For Shell scripts**:
- Use shellcheck: `shellcheck script.sh`
- Follow existing conventions
- Comment complex logic

### 3. Testing

**Before submitting a PR**:
```bash
# Run all tests
pytest tests/ -v

# Check shell script syntax
shellcheck bin/*.sh
shellcheck src/*.sh

# Verify configuration
./bin/check_environment.sh
./bin/helper_man.py --validate-only
```

### 4. Commit & Push
```bash
git add .
git commit -m "feat: brief description of changes"
git push origin feature/your-feature-name
```

### 5. Submit Pull Request

Include:
- Description of changes
- Tests added/modified
- Link to related issues

## Code Style Guide

### Python

```python
"""
Module docstring explaining purpose.
"""

from typing import Optional, Tuple, List


def function_name(param1: str, param2: int) -> Optional[Tuple[int, int]]:
    """
    Brief description of function.
    
    Longer description if needed, explaining behavior
    and any important details.
    
    Args:
        param1: Description of param1
        param2: Description of param2
        
    Returns:
        Description of return value
        
    Raises:
        ValueError: When something is invalid
    """
    # Implementation
    pass


class ClassName:
    """Brief class description."""
    
    def __init__(self, param: str):
        """Initialize the class."""
        self.param = param
    
    def method(self) -> str:
        """Brief method description."""
        return self.param
```

### Shell Scripts

```bash
#!/bin/bash

# Brief description of script purpose

set -e  # Exit on error

# Use meaningful variable names
INPUT_FILE="$1"
OUTPUT_DIR="$2"

# Use functions for reusable logic
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Error handling
if [[ ! -f "$INPUT_FILE" ]]; then
    log_message "Error: Input file not found"
    exit 1
fi

# Main logic
log_message "Processing: $INPUT_FILE"
```

## Adding Features

### Adding Configuration Parameters

1. **Update ConfigManager**:
   ```python
   # In xray_scripting/config.py
   MANDATORY_FLAGS = {
       'new_param': str,  # or int, etc.
   }
   ```

2. **Add Getter Method**:
   ```python
   def get_new_param(self) -> str:
       """Get new_param value."""
       return self.config.get('new_param', 'default').strip()
   ```

3. **Add Validation** (if needed):
   ```python
   # In validator.py
   def _validate_new_param(self) -> None:
       """Validate new_param."""
       value = self.config.get_new_param()
       if not value:
           self.errors.append("new_param is required")
   ```

4. **Add Test**:
   ```python
   # In tests/test_config.py
   def test_new_param(self):
       """Test new_param retrieval."""
       config = ConfigManager()
       config.config = {'new_param': 'test_value'}
       assert config.get_new_param() == 'test_value'
   ```

### Adding Validation Checks

1. Create method in ConfigValidator
2. Call from validate_all()
3. Write tests in tests/test_validator.py
4. Document in docs/

### Adding New Pipeline Step

1. Create `step_XX.sh` in src/
2. Test with sample data
3. Update manager.sh to call new step
4. Document in README.md

## Testing Guidelines

### Unit Tests

```python
import pytest
from xray_scripting import ConfigManager

def test_config_loading():
    """Test that config loads successfully."""
    config = ConfigManager("config.info")
    assert config.load() is True
    assert len(config.errors) == 0
```

### Integration Tests

```bash
#!/bin/bash
# Test pipeline with sample data

./bin/helper_man.py --dry-run
./bin/check_environment.sh
```

### Test Coverage

Aim for >80% coverage:
```bash
pytest tests/ --cov=xray_scripting --cov-report=html
```

## Documentation

### Docstrings

All public functions and classes must have docstrings:

```python
def public_function(param: str) -> bool:
    """
    Brief one-line description.
    
    Longer description explaining purpose, behavior,
    and any important details or assumptions.
    
    Args:
        param: Parameter description
        
    Returns:
        bool: Description of return value
        
    Raises:
        ValueError: If param is invalid
    """
```

### Code Comments

Comment complex logic, not obvious code:

```python
# Good - explains why
# Use Löwdin populations for stability (not Mulliken)
loewdin_pop = parse_loewdin(file)

# Bad - states the obvious
# Convert string to integer
value = int(value)
```

## Issues & Discussions

- **Report bugs** with reproducible examples
- **Suggest features** with use cases
- **Ask questions** in discussions (not issues)

## Release Process

1. Update version in `xray_scripting/__init__.py`
2. Update `CHANGELOG.md`
3. Create git tag: `git tag v1.2.3`
4. Push tag: `git push origin v1.2.3`

## Questions?

- Check existing issues/discussions
- Review documentation in docs/
- Ask in pull request comments

Thank you for contributing! :)
