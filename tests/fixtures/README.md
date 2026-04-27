# Test Fixtures - Reference Data for Regression Testing

## Directory Structure

```
tests/fixtures/
├── reference_data/
│   ├── nosoc/              # nosoc case (no spin-orbit coupling)
│   │   ├── resA_MOcore_AB_4.0A_1-26.csv
│   │   ├── resB_MOvirt_AB_4.0A_1-26.csv
│   │   ├── corevirtMO_matrix_AB_4.0A_1-26.csv
│   │   ├── corevirtMO_matrix_tspb_AB_4.0A_1-26.csv
│   │   ├── corevirt_fosc_AB_4.0A_1-26.csv
│   │   └── corevirt_foscw_AB_4.0A_1-26.csv
│   │
│   └── soc/                # soc case (spin-orbit coupling)
│       ├── resA_MOcore_AB_5.0A_25-799.csv
│       ├── resB_MOvirt_AB_5.0A_25-799.csv
│       ├── corevirtMO_matrix0_AB_5.0A_25-799.csv
│       ├── corevirtMO_matrix1_AB_5.0A_25-799.csv
│       ├── corevirtMO_matrix0_tspb_AB_5.0A_25-799.csv
│       ├── corevirtMO_matrix1_tspb_AB_5.0A_25-799.csv
│       ├── corevirt_fosc0_corr_AB_5.0A_25-799.csv
│       ├── corevirt_fosc1_corr_AB_5.0A_25-799.csv
│       ├── corevirt_foscw0_corr_AB_5.0A_25-799.csv
│       └── corevirt_foscw1_corr_AB_5.0A_25-799.csv
│
└── README.md               # This file
```

## Reference Data Details

### nosoc/ - No Spin-Orbit Coupling Case (AB_4.0A)

**Configuration:**
- Core atoms: C (carbon)
- Orbital type: s 
- MO range: 1-26 (FY toy model for fast testing)
- Single state (no multiplicity variations)

**Files:**
- `resA_MOcore_*.csv`: core MOs population
- `resB_MOvirt_*.csv`: virtual MOs populations
- `corevirtMO_matrix_*.csv`: number of core-virtual coupling MOs
- `corevirtMO_matrix_tspb_*.csv`: core-virtual MOs transition density population
- `corevirt_fosc_*.csv`: Transition dipole moment intensities (summation)
- `corevirt_foscw_*.csv`: Transition dipole moment  intensities (weighted summation)

**Use Case:** Fast regression testing for standard calculations without SOC

### soc/ - Spin-Orbit Coupling Case (AB_5.0A)

**Configuration:**
- Core atom: S (sulfur)
- Orbital type: p (pi)
- MO range: 25-799 (MW toy model)
- Multiple multiplicity states (state 0 and state 1)

**Files:**
- `resA_MOcore_*.csv`: core MOs population
- `resB_MOvirt_*.csv`: virtual MOs populations
- `corevirtMO_matrix0_*.csv`: number of core-virtual coupling MOs same-spin transition state
- `corevirtMO_matrix1_*.csv`: number of core-virtual coupling MOs changing-spin transition state
- `corevirt_fosc0_corr_*.csv`: Transition dipole moment intensities same-spin transition state
- `corevirt_fosc1_corr_*.csv`: Transition dipole moment intensities changing-spin transition state
- `corevirt_foscw0_corr_*.csv`: Transition dipole moment intensities same-spin transition state
- `corevirt_foscw1_corr_*.csv`: Transition dipole moment intensities changing-spin transition state

**Use Case:** Comprehensive regression testing including spin-orbit coupling effects

## Accessing Fixtures in Tests

### Using Pytest Fixtures (Recommended)

```python
import pytest
from pathlib import Path

class TestRegressionNOSOC:
    def test_with_fixture(self, nosoc_reference_dir):
        """Access reference data using fixture."""
        mocore_file = nosoc_reference_dir / 'resA_MOcore_AB_4.0A_1-26.csv'
        assert mocore_file.exists()
```

### Available Fixtures

From `conftest.py`:

- `tests_dir`: Root tests directory
- `fixtures_dir`: `tests/fixtures/`
- `reference_data_dir`: `tests/fixtures/reference_data/`
- `nosoc_reference_dir`: nosoc reference data directory
- `soc_reference_dir`: soc reference data directory
- `pipeline_output_dir`: Output directory for pipeline regression testing
- `nosoc_pipeline_output`: nosoc pipeline output directory
- `soc_pipeline_output`: soc pipeline output directory

### Using Directly in Code

```python
from pathlib import Path

tests_dir = Path(__file__).parent.parent
nosoc_dir = tests_dir / 'fixtures' / 'reference_data' / 'nosoc'
soc_dir = tests_dir / 'fixtures' / 'reference_data' / 'soc'
```

## Best Practices

1. **Always use fixtures for paths**: Ensures consistent access and makes tests portable
2. **Keep data immutable**: Reference data should not be modified by tests
3. **Document data source**: Add comments noting where reference data came from
4. **Version control**: Commit reference data with version history for reproducibility
5. **Organize by test type**: Group related fixtures (reference_data, pipeline_output, etc.)

## Adding New Reference Data

New reference data should be as small as the "toy model" like in the AB_4.0A (FY pair of amino acids)
and AB_5.0A (MW pair of amino acids) enabling fast testing times.
Add chemical explanation and detailed metadata information in [examples_overview](../examples/examples_overview.md)


When adding new toy models or test cases:

1. Create a new subdirectory under `reference_data/`:
   ```bash
   mkdir -p tests/fixtures/reference_data/new_case/
   ```

2. Place CSV files in the new directory

3. Create or update fixtures in `conftest.py`:
   ```python
   @pytest.fixture(scope="session")
   def new_case_reference_dir(reference_data_dir):
       """Reference data for new test case."""
       return reference_data_dir / "new_case"
   ```

4. Update `tests/` directory documentation

## Data Format

All reference data files are CSV (comma-separated values) format:

As simpler as follow the format presented in the reference data.

- **MOcore/MOvirt files**: `num-1, sym, lvl, MO_1, MO_2, ..., MO_N`
- **Matrix files**: Index row, then MO columns with numeric interaction values
- **Oscillator strength files**: Matrix format with fosc values

See `docs/data_processing_test.md` for detailed format specifications.

## Size and Performance

- **nosoc**: ~1-5 KB per file (fast, suitable for CI/CD)
- **soc**: ~50-500 KB per file (still fast, comprehensive testing)
- **Total**: ~10 MB (very manageable for Git)

## Related Documentation

- [docs/data_processing_test.md.md](../docs/docs/data_processing_test.md.md) - Testing strategy and methodology
- [regression_testing_examples.md](../docs/regression_testing_examples.md) - Integration examples
- [test_data_processing.py](../test_data_processing.py) - Test implementation
