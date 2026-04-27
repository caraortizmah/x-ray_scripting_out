# Data Processing Test Strategy - Regression Testing

## Overview

This document explains the regression testing framework for validating pipeline calculations using toy model reference data.

## Purpose

**Before Commit/PR Workflow:**
1. Developer makes code changes
2. Developer runs the pipeline with toy models:
   - **AB_4.0A**: nosoc case (same spin-state) - C atoms, s orbitals
   - **AB_5.0A**: soc case (changing spin-state) - S atom, p orbital
3. Regression tests compare pipeline OUTPUT against reference CSV data
4. If results match numerically -> &check; test passes -> allow git push/PR
5. If results diverge -> &cross; test fails -> reject commit (catch regressions)

## Reference Data Location

**Standard location**: `tests/fixtures/reference_data/`

Following Python best practices, test fixtures are organized under the `tests/` directory:

```
tests/
├── conftest.py                    # Pytest configuration and shared fixtures
├── fixtures/
│   ├── README.md                  # Fixtures documentation
│   └── reference_data/
│       ├── nosoc/                 # nosoc case (no spin-orbit coupling)
│       │   ├── resA_MOcore_AB_4.0A_1-26.csv
│       │   ├── resB_MOvirt_AB_4.0A_1-26.csv
│       │   ├── corevirtMO_matrix_AB_4.0A_1-26.csv
│       │   └── ... (6 files total)
│       │
│       └── soc/                   # soc case (spin-orbit coupling)
│           ├── resA_MOcore_AB_5.0A_25-799.csv
│           ├── resB_MOvirt_AB_5.0A_25-799.csv
│           ├── corevirtMO_matrix0_AB_5.0A_25-799.csv
│           ├── corevirtMO_matrix1_AB_5.0A_25-799.csv
│           └── ... (10 files total)
│
└── test_data_processing.py        # Regression test implementation
```

## Data Format Examples

### MOcore/MOvirt Format 
## (ResA... case)
```csv
num-1,sym,lvl,7,8,9,10,11,12,...
1,C,s,0.0,0.0,0.0,0.0,99.6,0.0,...
2,C,s,99.6,0.0,0.0,0.0,0.0,0.0,...
5,C,s,0.0,0.0,0.0,0.0,0.0,0.0,...
```
## (ResB... case)
```csv
num-1,sym,lvl,81,90,92,112,...
0,N,lvlMO,2.45,0.0,34.2,0.0,13.2,0.0,...
1,C,lvlMO,9.6,0.3,0.0,3.2,11.7,0.0,...
2,O,lvlMO,12.7,23.4,3.1,5.3,14.7,0.0,...
3,O,lvlMO,12.7,23.4,3.1,5.3,14.7,0.0,...
```

- **num-1**: Atom serial number (ordered coordinates, that is not atomic number!)
- **sym**: Atom symbol (C, N, O, etc.)
- **lvl**: Orbital type (s, p, d, f)
- **Columns 4+**: MO populations (0-100 scale usually) for each molecular orbital

### corevirtMO_matrix Format
```csv
virt\core,7,8,9,10,11,12,...
92,1,1,1,1,1,1,...
93,0,0,0,0,0,2,...
```
- Index: Virtual MO indices
- Columns: Core MO indices
- Values: Interaction strength/count

## Test Structure

### 1. **Reference Fixture Validation** (`TestNOSOCRegressionAB40`, `TestSOCRegressionAB50`)
Tests that verify the reference data files exist and are valid:
- &check; File existence checks
- &check; CSV structure validation (correct columns)
- &check; Data type validation (numeric values)
- &check; Expected atom types/orbitals (nosoc: C/O/N + s; soc: S + p)
- &check; Value range either serial atoms and MOs validation (usual ranges 0-100)

### 2. **Regression Tests** (`TestPipelineRegressionNOSOC`, `TestPipelineRegressionSOC`)
Tests that compare pipeline OUTPUT against reference data:
- Compares calculated MOcore populations against reference
- Compares calculated core-virtual matrices against reference
- Validates previous information in the two spin-state possibilities (soc case only)
- Uses numerical tolerance for floating-point comparisons
- **Status**: Currently skipped, activated when pipeline output is available

### 3. **Tolerance Levels**
Different tolerances for different data types:

| Data Type | Relative Tolerance | Absolute Tolerance | Notes |
|-----------|-------------------|-------------------|-------|
| Populations (MOcore/MOvirt) | 1e-5 (0.001%) | 0.1 | Population percentages |
| Matrices (counts/interactions) | 0 | 1 | Integer counts, allow ±1 |
| Oscillator strengths | 1e-5 | 0.1 | Floating-point values |

## Developer Workflow - Using Regression Tests

### Step 1: Make Code Changes
```bash
# Developer modifies pipeline code
git checkout -b feature/my-optimization
# ... edit src/step*.sh or xray_scripting/*.py ...
```

### Step 2: Run Pipeline with Toy Models
```bash
# Prepare pipeline inputs (orca output and config.info)
cp examples/AB_4.0A.out input/
cp examples/config.info_examplenosoc config.info 
# Run pipeline with nosoc toy model (AB_4.0A)
./bin/helper_man.py
# copy or move the csv data 
cp -r output/pop_matrices/AB_4.0A.out_csv output/ab40_test
# inside ab40_test the 6 csv files should be found

# Prepare pipeline inputs II (orca output and config.info)
cp examples/AB_5.0A.out input/
cp examples/config.info_examplesoc config.info
# Run pipeline with soc toy model (AB_5.0A)
./bin/helper_man.py
# copy or move the csv data 
cp -r output/pop_matrices/AB_5.0A.out_csv output/ab50_test
# inside ab50_test the 10 csv files should be found
```

### Step 3: Run Regression Tests
```bash
# Run all regression tests (validates output matches reference)
pytest tests/test_data_processing.py::TestPipelineRegressionNOSOC -v
pytest tests/test_data_processing.py::TestPipelineRegressionSOC -v

# Run specific test
pytest tests/test_data_processing.py::TestPipelineRegressionNOSOC::test_nosoc_mocore_output_matches_reference -v
```

### Step 4: Commit or Create PR
```bash
# Only if tests pass
git add .
git commit -m "Optimize calculation algorithm"
git push

# Or create PR after validation
gh pr create --title "Optimization PR"
```

## How to Activate Regression Tests

The regression tests are currently **skipped** because they require pipeline output. To activate them:

### Option 1: Manual Output Setup
```python
# In test fixture, point to pipeline output directory
@pytest.fixture
def nosoc_output_dir(self):
    """Pipeline output from running AB_4.0A toy model."""
    return Path('/path/to/pipeline/output/ab40_test')
```

### Option 2: CI/CD Integration (Recommended)
```yaml
# In GitHub Actions / GitLab CI
- name: Run pipeline with toys models
  run: |
    ./manager.sh input/AB_4.0A.out config_nosoc.info output/ab40_test
    ./manager.sh input/AB_5.0A.out config_soc.info output/ab50_test

- name: Run regression tests
  run: pytest tests/test_data_processing.py -v --tb=short
```

## How to Extend the Tests

### Add New Regression Test

```python
class TestPipelineRegressionNOSOC(TestRegressionBase):
    """Existing regression tests for nosoc case."""
    
    def test_nosoc_fosc_matches_reference(self):
        """New test: Oscillator strengths match reference."""
        ref_file = self.nosoc_dir / 'corevirt_fosc_AB_4.0A_1-26.csv'
        reference = self.load_csv(ref_file)
        
        # Load pipeline output
        output_file = self.nosoc_output_dir / 'corevirt_fosc_AB_4.0A_1-26.csv'
        output = self.load_csv(output_file)
        
        # Compare with appropriate tolerance for oscillator strengths
        is_match, diff = self.compare_dataframes(
            reference, 
            output, 
            rtol=1e-5,      # Tight relative tolerance
            atol=0.01       # Allow 0.01 deviation in fosc values
        )
        assert is_match, f"Oscillator strengths don't match: {diff}"
```

### Add Cross-Case Validation

```python
def test_nosoc_soc_consistency(self):
    """Verify nosoc and soc cases produce consistent intermediate results."""
    # Load nosoc MOcore
    nosoc_mocore = self.load_csv(
        self.nosoc_dir / 'resA_MOcore_AB_4.0A_1-26.csv'
    )
    
    # Load soc MOcore (subset of MOs)
    soc_mocore = self.load_csv(
        self.soc_dir / 'resA_MOcore_AB_5.0A_25-799.csv'
    )
    
    # Compare atoms where they overlap
    # (nosoc uses MOs 1-26, soc uses MOs 25-799)
    # Atoms should be numbered consistently
    assert nosoc_mocore['num-1'].max() > 0
    assert soc_mocore['num-1'].max() > 0
```

### Adjust Tolerance for Different Scenarios

```python
# Loose tolerance (allow larger deviations)
is_match = self.compare_dataframes(ref, out, rtol=1e-3, atol=1.0)

# Medium tolerance (default for populations)
is_match = self.compare_dataframes(ref, out, rtol=1e-5, atol=0.1)

# Strict tolerance (for integer counts)
is_match = self.compare_dataframes(ref, out, rtol=0, atol=0.5)
```

## Running the Tests

### Validate Reference Data (Always Passes)
```bash
# Check that reference fixtures are valid
pytest tests/test_data_processing.py::TestNOSOCRegressionAB40 -v
pytest tests/test_data_processing.py::TestSOCRegressionAB50 -v

# Run all reference validation
pytest tests/test_data_processing.py -k "NOSOC or SOC" -v
```

### Run Regression Tests (Requires Pipeline Output)
```bash
# These tests are skipped by default (output not available)
# After running pipeline with toy models:
pytest tests/test_data_processing.py::TestPipelineRegressionNOSOC -v
pytest tests/test_data_processing.py::TestPipelineRegressionSOC -v

# Run all tests
pytest tests/test_data_processing.py -v
```

### Run Specific Test
```bash
# Test a single regression check
pytest tests/test_data_processing.py::TestPipelineRegressionNOSOC::test_nosoc_mocore_output_matches_reference -v

# Run with detailed output
pytest tests/test_data_processing.py::TestPipelineRegressionNOSOC -v -s --tb=short
```

### Integration with Pipeline Testing
```bash
# Full workflow: prepare -> run -> test
./manager.sh input/AB_4.0A.out config.info output/ab40_test  # Run with AB_4.0A
pytest tests/test_data_processing.py::TestPipelineRegressionNOSOC -v  # Validate

./manager.sh input/AB_5.0A.out config.info output/ab50_test  # Run with AB_5.0A
pytest tests/test_data_processing.py::TestPipelineRegressionSOC -v  # Validate
```

## Test Coverage Strategy

### Phase 1: Reference Fixture Setup (Current &check;)
- &check; Reference data validation
- &check; File existence and structure checks
- &check; Data integrity verification (nosoc/soc cases)
- &check; Baseline numeric constraints

### Phase 2: Regression Testing (In Progress)
- \ Activate regression tests with pipeline output
- \ Validate MOcore populations
- \ Validate core-virtual matrices
- \ Validate oscillator strength calculations
- \ Cross-validate nosoc vs soc consistency

### Phase 3: Enhanced Validation (Future)
- Pipeline output file format validation
- Intermediate calculation checkpoints
- Performance regression detection
- Numerical accuracy trending (detect drift over commits)

## Key Features

1. **Regression Detection**: Detects when code changes alter results unintentionally
2. **Toy Model Advantage**: Fast tests (small datasets), easy debugging, known good outputs
3. **Dual Coverage**: nosoc (C/O/N + s) and soc (S + p) cases cover different code paths
4. **Configurable Tolerance**: Adjust thresholds per data type and precision needs
5. **CI/CD Ready**: Integrates into automated testing pipelines
6. **Developer Friendly**: Clear messages on what diverged and by how much

## Benefits of This Approach

| Benefit | Description |
|---------|-------------|
| **Catch Regressions Early** | Spot accidental changes before production use |
| **Safe Refactoring** | Optimize code confidently knowing tests prevent breakage |
| **Documentation** | Reference outputs document expected behavior |
| **Version Control** | Track calculation accuracy across commits |
| **Code Review** | PRs automatically validated against known good outputs |
| **Debug Friendly** | Small toy models = faster iteration when fixing issues |
| **Maintenance** | Tests ensure compatibility across code changes/updates |
