# Regression Testing Examples

Usage Examples and Configuration for Regression Testing

This document provides practical examples for running regression tests locally and in CI/CD.

For complete test documentation, rationale, and detailed explanations, see:
- [docs/data_processing_tests.md](data_processing_tests.md) - Full test structure, tolerance levels, and developer workflows

#### ============================================================================
### TEST TYPES OVERVIEW
#### ============================================================================

Three types of tests in test_data_processing.py:

1. REFERENCE FIXTURE VALIDATION (TestNOSOCRegressionAB40, TestSOCRegressionAB50)
   Purpose: Validate reference data files exist and conform to expected structure
   Status: Always run, fast validation
   Checks: File existence, CSV structure, atom ranges (Atom_number_range_A/B),
           MO ranges (core_MO_range), population ranges, data types
   
2. PIPELINE OUTPUT REGRESSION (TestPipelineRegressionNOSOC, TestPipelineRegressionSOC)
   Purpose: Compare pipeline OUTPUT against reference data to detect calculation changes
   Status: Runs after pipeline execution completes
   Checks: MOcore populations match reference (rtol=1e-5, atol=0.1)
           Core-virtual matrices match reference (rtol=0, atol=1)
           Multiplicity states (soc only) match reference
   
3. test_data_processing MODULE
   Purpose: Unified test module combining both reference validation and regression tests
   Integration: Reference tests run first, then pipeline tests if output available


#### ============================================================================
### SETUP: Prepare Pipeline Output Before Testing
#### ============================================================================

The regression tests compare pipeline outputs in output/ab40_test/ and output/ab50_test/
against reference data in tests/fixtures/reference_data/{nosoc,soc}/.

BEFORE RUNNING REGRESSION TESTS:

1. Run pipeline with toy models using corresponding config files:
   
   Use tester.sh exclusively for regression tests.
   Be sure that input and output paths of config.info examples
   fit accordingly to the path you are working at

   For nosoc (AB_4.0A) case:
```bash
   ./tests/tester.sh ab40_test AB_4.0A.out config.info_examplenosoc
```   
   For soc (AB_5.0A) case:
```bash
   ./tests/tester.sh ab50_test AB_5.0A.out config.info_examplesoc
```

2. Now run regression tests (see examples below)

For detailed pipeline execution documentation, see: [docs/quickstart.md](quickstart.md)


#### ============================================================================
### EXAMPLE 1: GitHub Actions CI/CD Configuration
#### ============================================================================

```yaml
File: .github/workflows/regression-tests.yml

name: Regression Tests
on: [push, pull_request]

jobs:
  regression-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pandas numpy
      
      - name: Prepare structure for data
        run: |
          mkdir -p input output
      
      - name: Validate reference fixtures (before pipeline runs)
        run: |
          pytest tests/test_data_processing.py::TestNOSOCRegressionAB40 -v
          pytest tests/test_data_processing.py::TestSOCRegressionAB50 -v
      
      - name: Run nosoc pipeline (AB_4.0A)
        run: ./tests/tester.sh ab40_test AB_4.0A.out config.info_examplenosoc
      
      - name: Run soc pipeline (AB_5.0A)
        run: ./tests/tester.sh ab50_test AB_5.0A.out config.info_examplesoc
      
      - name: Run pipeline regression tests (nosoc)
        run: pytest tests/test_data_processing.py::TestPipelineRegressionNOSOC -v
      
      - name: Run pipeline regression tests (soc)
        run: pytest tests/test_data_processing.py::TestPipelineRegressionSOC -v
      
      - name: Archive results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: output/
```

#### ============================================================================
### EXAMPLE 2: Local Development Workflow
#### ============================================================================

```
Developer Workflow: Make changes -> Validate reference -> Run pipeline -> Test against reference
```

Step 1: Create feature branch and make code changes
```bash
    git checkout -b feature/optimize-calculations
    # ... edit src/step*.sh or xas_qmol_parser/*.py ...
    git add .
    git commit -m "Optimize MO population calculations"
```

Step 2: Quick validation - confirm reference fixtures are valid
```bash
    pytest tests/test_data_processing.py::TestNOSOCRegressionAB40 -v
    pytest tests/test_data_processing.py::TestSOCRegressionAB50 -v
```
    
    (These tests check that reference data files conform to config.info ranges)

Step 3: Run pipeline with toy models (uses corresponding config files)
```bash
    ./tests/tester.sh ab40_test AB_4.0A.out config.info_examplenosoc
    ./tests/tester.sh ab50_test AB_5.0A.out config.info_examplesoc
```

Step 4: Run regression tests - compare pipeline outputs against reference
```bash
    pytest tests/test_data_processing.py::TestPipelineRegressionNOSOC -v
    pytest tests/test_data_processing.py::TestPipelineRegressionSOC -v
```
    
    (If all tests pass, calculations haven't changed unintentionally)

Step 6: All tests pass -> Create PR
```bash
    git push origin feature/optimize-calculations
    # Create PR in GitHub/GitLab
    # CI/CD runs full test suite again
```

ALTERNATIVE: Run all tests at once
```bash
    pytest tests/test_data_processing.py -v
```
    (Runs reference validation + pipeline regression tests together)


#### ============================================================================
### QUICK REFERENCE: Test Types and Commands
#### ============================================================================

Test Type 1: REFERENCE FIXTURE VALIDATION
```
-----------
Tests: TestNOSOCRegressionAB40, TestSOCRegressionAB50
Purpose: Validates reference data structure conforms to config.info ranges
When to run: ALWAYS, BEFORE pipeline execution
Pipeline output needed: NO
```
Command:
```bash
    pytest tests/test_data_processing.py::TestNOSOCRegressionAB40 -v   # nosoc fixtures
    pytest tests/test_data_processing.py::TestSOCRegressionAB50 -v     # soc fixtures
```
What it checks:
-    &check; Reference files exist in tests/fixtures/reference_data/
-    &check; Column headers (MO number ranges) are in core_MO_range from config.info
-    &check; Row indices (atom numbers) are in Atom_number_range_A and all atoms in Atom_number_range_B
-    &check; Virtual MOs are NOT in core_MO_range
-    &check; Population values are in 0-100 range
-    &check; All corevirt* files exist (4 for nosoc, 8 for soc)

---

Test Type 2: PIPELINE OUTPUT REGRESSION
```
-----------
Tests: TestPipelineRegressionNOSOC, TestPipelineRegressionSOC
Purpose: Compares pipeline calculations against reference to detect regressions
When to run: AFTER pipeline execution and output files moved to ab40_test/ and ab50_test/
Pipeline output needed: YES
Prerequisites:
    1. Run manager.sh with toy models (see Step 3 in Example 2)
    2. Copy output matrices to test directories (see Step 4 in Example 2):
```
Command:
```bash
       cp -r output/pop_matrices/AB_4.0A.out_csv/* output/ab40_test/
       cp -r output/pop_matrices/AB_5.0A.out_csv/* output/ab50_test/
```
Command:
```bash
    pytest tests/test_data_processing.py::TestPipelineRegressionNOSOC -v   # nosoc outputs
    pytest tests/test_data_processing.py::TestPipelineRegressionSOC -v     # soc outputs
```
What it checks:
-    &check; resA_MOcore (core MO populations) match reference (rtol=1e-5, atol=0.1)
-    &check; corevirtMO_matrix (core-virtual interactions) match reference (rtol=0, atol=1)
-    &check; corevirtMO_matrix0 and matrix1 (soc multiplicity states) match reference
-    &check; No unintended changes in calculations

---

Test Type 3: COMPLETE REGRESSION TEST SUITE
```
-----------
Command: pytest tests/test_data_processing.py -v
Purpose: Runs all tests (Types 1 + 2) in sequence
Behavior:
    - First: Validates reference fixtures (fast, always passes)
    - Then: Runs pipeline regression if output files found, otherwise skips
    - Total: ~20+ tests covering both reference validation and regression checks
Expected output:
    - &check; 17 tests pass (8 nosoc + 9 soc reference validation)
    - &check; 5 tests pass (2 nosoc + 3 soc pipeline regression, if outputs present)
    - Total: 22 passed
```
For more detailed information on test structure, tolerances, and workflows:
See: [docs/data_processing_tests.md](data_processing_tests.md)


#### ============================================================================
### EXAMPLE 3: Configuration with Pytest Fixtures
#### ============================================================================
This part has a lot to check so, as developer, you are here by your own :)


```python
File: conftest.py (pytest configuration)

import pytest
from pathlib import Path

@pytest.fixture(scope="session")
def repo_root():
    '''Return repository root directory.'''
    return Path(__file__).parent

@pytest.fixture(scope="session")
def pipeline_output_dir(repo_root):
    '''Return pipeline output directory.'''
    output_dir = repo_root / "output"
    output_dir.mkdir(exist_ok=True)
    return output_dir

@pytest.fixture(scope="session")
def nosoc_output(pipeline_output_dir):
    '''Return AB_4.0A (nosoc) output directory.'''
    return pipeline_output_dir / "ab40_test"

@pytest.fixture(scope="session")
def soc_output(pipeline_output_dir):
    '''Return AB_5.0A (soc) output directory.'''
    return pipeline_output_dir / "ab50_test"
```

#### ============================================================================
### EXAMPLE 4: Pytest Configuration with pytest.ini
#### ============================================================================

```
# In test_data_processing.py:
# def test_pipeline(nosoc_output):
#     assert (nosoc_output / "resA_MOcore_AB_4.0A_1-26.csv").exists()

File: pytest.ini

[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*

# Add markers for test selection
markers =
    regression: Regression tests against reference data
    reference: Reference fixture validation
    slow: Slow tests (require pipeline execution)
    nosoc: Tests for nosoc case (AB_4.0A)
    soc: Tests for soc case (AB_5.0A)

# Command: pytest -m regression  (run only regression tests)
# Command: pytest -m nosoc       (run only nosoc tests)
```

#### ============================================================================
### EXAMPLE 5: Running Tests with Different Filters
#### ============================================================================

```bash
# Validate reference fixtures only (fast)
pytest tests/test_data_processing.py -m reference -v

# Run nosoc regression tests
pytest tests/test_data_processing.py -m nosoc -v

# Run soc regression tests
pytest tests/test_data_processing.py -m soc -v

# Run all regression tests
pytest tests/test_data_processing.py -m regression -v

# Run excluding slow tests
pytest tests/ -m "not slow" -v

# Run with custom output
pytest tests/test_data_processing.py -v --tb=short --junit-xml=results.xml
```

#### ============================================================================
### EXAMPLE 6: Setting Output Directory Dynamically
#### ============================================================================
```python
In test code, set the output directory from environment variable:

import os
from pathlib import Path

class TestPipelineRegressionNOSOC(TestRegressionBase):
    
    @pytest.fixture
    def nosoc_output_dir(self):
        '''Get output directory from environment or use default.'''
        output_dir = Path(os.getenv(
            'NOSOC_OUTPUT_DIR',
            'output/ab40_test'
        ))
        
        if not output_dir.exists():
            pytest.skip(f"Output directory not found: {output_dir}")
        
        return output_dir

# Usage:
# NOSOC_OUTPUT_DIR=./output/custom_nosoc pytest tests/test_data_processing.py -v
```

#### ============================================================================
### EXAMPLE 7: Custom Tolerance Configuration
#### ============================================================================

For different code paths or calculation precision levels:
```python
class TestPipelineRegressionNOSOC(TestRegressionBase):
    
    # Tolerances per calculation type
    TOLERANCES = {
        'populations': {'rtol': 1e-5, 'atol': 0.1},    # Tight for populations
        'matrices': {'rtol': 0, 'atol': 1},             # Integer counts
        'fosc': {'rtol': 1e-4, 'atol': 0.01},          # Moderate for oscillator strengths
    }
    
    def test_mocore_with_tolerance(self, nosoc_output_dir):
        ref = self.load_csv(self.nosoc_dir / 'resA_MOcore_AB_4.0A_1-26.csv')
        out = self.load_csv(nosoc_output_dir / 'resA_MOcore_AB_4.0A_1-26.csv')
        
        tol = self.TOLERANCES['populations']
        is_match, diff = self.compare_dataframes(ref, out, **tol)
        assert is_match, f"MOcore mismatch: {diff}"
```

