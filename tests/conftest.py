"""
Pytest configuration and shared fixtures for X-ray spectroscopy pipeline tests.

Standard location: tests/conftest.py (auto-discovered by pytest)
Test data location: tests/fixtures/reference_data/
"""

import pytest
from pathlib import Path


@pytest.fixture(scope="session")
def tests_dir():
    """Return the tests directory."""
    return Path(__file__).parent


@pytest.fixture(scope="session")
def fixtures_dir(tests_dir):
    """Return the test fixtures directory."""
    return tests_dir / "fixtures"


@pytest.fixture(scope="session")
def reference_data_dir(fixtures_dir):
    """Return the reference data directory containing regression test fixtures."""
    return fixtures_dir / "reference_data"


@pytest.fixture(scope="session")
def nosoc_reference_dir(reference_data_dir):
    """
    Return the nosoc (no spin-orbit coupling) reference data directory.
    
    Contains: AB_4.0A toy model data
    - Core atoms: C, O, N
    - Orbital type: s
    - MO range: 1-26
    """
    return reference_data_dir / "nosoc"


@pytest.fixture(scope="session")
def soc_reference_dir(reference_data_dir):
    """
    Return the soc (spin-orbit coupling) reference data directory.
    
    Contains: AB_5.0A toy model data
    - Core atom: S
    - Orbital type: p
    - MO range: 25-799
    - Multiple multiplicity states
    """
    return reference_data_dir / "soc"


@pytest.fixture(scope="session")
def pipeline_output_dir(tests_dir):
    """Return the pipeline output directory for regression test comparisons."""
    output_dir = tests_dir.parent / "output"
    output_dir.mkdir(exist_ok=True)
    return output_dir


@pytest.fixture(scope="session")
def nosoc_pipeline_output(pipeline_output_dir):
    """
    Return the nosoc pipeline output directory.
    
    This is populated by running the pipeline with the AB_4.0A toy model.
    Used to compare against nosoc reference data.
    """
    output_dir = pipeline_output_dir / "nosoc_test"
    output_dir.mkdir(exist_ok=True)
    return output_dir


@pytest.fixture(scope="session")
def soc_pipeline_output(pipeline_output_dir):
    """
    Return the soc pipeline output directory.
    
    This is populated by running the pipeline with the AB_5.0A toy model.
    Used to compare against soc reference data.
    """
    output_dir = pipeline_output_dir / "soc_test"
    output_dir.mkdir(exist_ok=True)
    return output_dir


# Pytest configuration
def pytest_configure(config):
    """Configure pytest with custom markers."""
    config.addinivalue_line(
        "markers", "regression: Regression tests against reference data"
    )
    config.addinivalue_line(
        "markers", "reference: Reference fixture validation"
    )
    config.addinivalue_line(
        "markers", "nosoc: Tests for nosoc case (AB_4.0A)"
    )
    config.addinivalue_line(
        "markers", "soc: Tests for soc case (AB_5.0A)"
    )
