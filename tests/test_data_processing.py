"""
Regression tests for data processing calculations using toy model reference data.

This module validates that reference data files conform to expected structure and constraints
derived from config.info settings:
- AB_4.0A: nosoc case - uses config.info_examplenosoc
- AB_5.0A: soc case - uses config.info_examplesoc

Tests verify that column headers (MO ranges) and row indices (atom numbers) match
the ranges specified in the respective config files.
"""

import pytest
import os
import sys
import pandas as pd
import numpy as np
from pathlib import Path

# Add package to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))


def parse_range(range_str):
    """Parse range string like '7-24' into (start, end) tuple."""
    try:
        start, end = range_str.split('-')
        return int(start), int(end)
    except:
        raise ValueError(f"Invalid range format: {range_str}")


def parse_config_file(filepath):
    """Load config.info file and extract key ranges."""
    config = {}
    try:
        with open(filepath, 'r') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('|') or line.startswith('-') or '=' not in line:
                    continue
                key, value = line.split('=')
                config[key.strip()] = value.strip()
    except Exception as e:
        pytest.skip(f"Could not parse config file {filepath}: {e}")
    
    return config


class TestRegressionBase:
    """Base class for regression tests against reference data."""
    
    @classmethod
    def setup_class(cls):
        """Set up reference data paths and load config files."""
        # Reference data location
        cls.tests_dir = Path(__file__).parent
        cls.fixtures_dir = cls.tests_dir / 'fixtures' / 'reference_data'
        cls.nosoc_dir = cls.fixtures_dir / 'nosoc'
        cls.soc_dir = cls.fixtures_dir / 'soc'
        
        # Config files location (examples folder at repo root)
        cls.repo_root = cls.tests_dir.parent
        cls.examples_dir = cls.repo_root / 'examples'
        
        # Skip if test data doesn't exist
        if not cls.fixtures_dir.exists():
            pytest.skip(f"Reference data directory not found: {cls.fixtures_dir}")
    
    @staticmethod
    def load_csv(filepath):
        """Load CSV file and return as DataFrame."""
        return pd.read_csv(filepath)
    
    @staticmethod
    def load_csv_matrix(filepath):
        """Load CSV matrix file (for corevirtMO_matrix etc.)."""
        df = pd.read_csv(filepath, index_col=0)
        return df
    
    @staticmethod
    def compare_dataframes(expected_df, actual_df, rtol=1e-5, atol=0.1):
        """
        Compare two DataFrames numerically with tolerance.
        
        Args:
            expected_df: Reference/expected DataFrame (from CSV)
            actual_df: Actual output DataFrame from pipeline
            rtol: Relative tolerance (default 1e-5 = 0.001%)
            atol: Absolute tolerance (default 0.1 for population percentages)
            
        Returns:
            tuple: (is_close, differences) where differences is a dict of issues
        """
        differences = {}
        
        # Check shape
        if expected_df.shape != actual_df.shape:
            differences['shape'] = f"Expected {expected_df.shape}, got {actual_df.shape}"
            return False, differences
        
        # Check columns
        if not expected_df.columns.equals(actual_df.columns):
            differences['columns'] = f"Column mismatch"
            return False, differences
        
        # Compare numeric values
        try:
            numeric_cols = expected_df.select_dtypes(include=[np.number]).columns
            for col in numeric_cols:
                exp_vals = pd.to_numeric(expected_df[col], errors='coerce')
                act_vals = pd.to_numeric(actual_df[col], errors='coerce')
                
                if not np.allclose(exp_vals, act_vals, rtol=rtol, atol=atol, equal_nan=True):
                    max_diff = np.nanmax(np.abs(exp_vals - act_vals))
                    differences[col] = f"Max difference: {max_diff:.6f}"
        except Exception as e:
            differences['comparison_error'] = str(e)
            return False, differences
        
        is_close = len(differences) == 0
        return is_close, differences
    
    @staticmethod
    def compare_matrices(expected_matrix, actual_matrix, rtol=1e-5, atol=1):
        """
        Compare two matrices with numerical tolerance.
        
        Args:
            expected_matrix: Expected matrix (DataFrame or numpy array)
            actual_matrix: Actual matrix (DataFrame or numpy array)
            rtol: Relative tolerance
            atol: Absolute tolerance (default 1 for count/integer data)
            
        Returns:
            bool: True if matrices match within tolerance
        """
        if isinstance(expected_matrix, pd.DataFrame):
            expected_matrix = expected_matrix.values
        if isinstance(actual_matrix, pd.DataFrame):
            actual_matrix = actual_matrix.values
        
        return np.allclose(expected_matrix, actual_matrix, rtol=rtol, atol=atol, equal_nan=True)


class TestNOSOCRegressionAB40(TestRegressionBase):
    """
    Reference data validation for nosoc case (AB_4.0A).
    
    Validates that reference data files conform to constraints from config.info_examplenosoc.
    """
    
    @classmethod
    def setup_class(cls):
        """Set up and load config for nosoc case."""
        super().setup_class()
        
        # Load config
        config_file = cls.examples_dir / 'config.info_examplenosoc'
        if not config_file.exists():
            pytest.skip(f"Config file not found: {config_file}")
        
        cls.config = parse_config_file(config_file)
        
        # Parse ranges from config
        cls.atom_range_a = parse_range(cls.config['Atom_number_range_A'])
        cls.atom_range_b = parse_range(cls.config['Atom_number_range_B'])
        cls.core_mo_range = parse_range(cls.config['core_MO_range'])
        cls.atm_core = cls.config['atm_core']
    
    def test_ab40_mocore_reference_exists(self):
        """Test that AB_4.0A MOcore reference file exists."""
        mocore_file = self.nosoc_dir / 'resA_MOcore_AB_4.0A_1-26.csv'
        assert mocore_file.exists(), f"Reference file not found: {mocore_file}"
    
    def test_ab40_mocore_structure_and_ranges(self):
        """Test AB_4.0A MOcore has correct structure and column/row ranges."""
        mocore_file = self.nosoc_dir / 'resA_MOcore_AB_4.0A_1-26.csv'
        df = self.load_csv(mocore_file)
        
        # Verify metadata columns exist
        assert 'num-1' in df.columns, "Missing 'num-1' column"
        assert 'sym' in df.columns, "Missing 'sym' column"
        assert 'lvl' in df.columns, "Missing 'lvl' column"
        assert len(df) > 0, "Reference data is empty"
        
        # Extract MO columns (integers after metadata)
        mo_columns = [int(col) for col in df.columns if str(col).isdigit()]
        
        # Verify MO columns are in core_MO_range and ordered
        core_start, core_end = self.core_mo_range
        assert all(core_start <= mo <= core_end for mo in mo_columns), \
            f"MO columns {mo_columns} not all in range {core_start}-{core_end}"
        assert mo_columns == sorted(mo_columns), \
            f"MO columns {mo_columns} are not ordered"
        
        # Verify atom numbers are in Atom_number_range_A
        atom_start, atom_end = self.atom_range_a
        atom_nums = df['num-1'].values
        assert all(atom_start <= num <= atom_end for num in atom_nums), \
            f"Atom numbers {atom_nums} not all in range {atom_start}-{atom_end}"
        
        # Verify atom type matches config
        assert df['sym'].unique()[0] == self.atm_core, \
            f"Expected atom type {self.atm_core}, got {df['sym'].unique()[0]}"
    
    def test_ab40_mocore_populations_valid(self):
        """Test that MOcore populations are in valid range (0-100)."""
        mocore_file = self.nosoc_dir / 'resA_MOcore_AB_4.0A_1-26.csv'
        df = self.load_csv(mocore_file)
        
        # Get MO columns (skip metadata)
        mo_columns = [col for col in df.columns if str(col).isdigit()]
        
        for col in mo_columns:
            values = pd.to_numeric(df[col], errors='coerce')
            assert not values.isna().any(), f"NaN in column {col}"
            assert (values >= 0).all() and (values <= 100).all(), \
                f"Invalid population range in column {col}: {values.min()}-{values.max()}"
    
    def test_ab40_movirt_reference_exists(self):
        """Test that AB_4.0A MOvirt reference file exists."""
        movirt_file = self.nosoc_dir / 'resB_MOvirt_AB_4.0A_1-26.csv'
        assert movirt_file.exists(), f"Reference file not found: {movirt_file}"
    
    def test_ab40_movirt_structure_and_ranges(self):
        """Test AB_4.0A MOvirt column headers are NOT in core_MO_range."""
        movirt_file = self.nosoc_dir / 'resB_MOvirt_AB_4.0A_1-26.csv'
        df = self.load_csv(movirt_file)
        
        # Extract virtual MO columns
        virtual_mo_columns = [int(col) for col in df.columns if str(col).isdigit()]
        
        # Verify virtual MOs are NOT in core_MO_range
        core_start, core_end = self.core_mo_range
        assert not any(core_start <= mo <= core_end for mo in virtual_mo_columns), \
            f"Virtual MOs {virtual_mo_columns} should NOT be in core range {core_start}-{core_end}"
    
    def test_ab40_movirt_contains_all_atoms(self):
        """Test that MOvirt rows contain all atom numbers in Atom_number_range_B."""
        movirt_file = self.nosoc_dir / 'resB_MOvirt_AB_4.0A_1-26.csv'
        df = self.load_csv(movirt_file)
        
        atom_start, atom_end = self.atom_range_b
        atom_nums = set(df['num-1'].values)
        expected_atoms = set(range(atom_start, atom_end + 1))
        
        assert atom_nums == expected_atoms, \
            f"Atom numbers {sorted(atom_nums)} don't match expected range {atom_start}-{atom_end}"
    
    def test_ab40_corevirt_files_exist(self):
        """Test that 4 corevirt* files exist for nosoc case."""
        expected_files = [
            'corevirtMO_matrix_AB_4.0A_1-26.csv',
            'corevirtMO_matrix_tspb_AB_4.0A_1-26.csv',
            'corevirt_fosc_AB_4.0A_1-26.csv',
            'corevirt_foscw_AB_4.0A_1-26.csv'
        ]
        for filename in expected_files:
            filepath = self.nosoc_dir / filename
            assert filepath.exists(), f"Reference file not found: {filepath}"
    
    def test_ab40_corevirt_matrix_ranges(self):
        """Test that corevirtMO_matrix has core MOs as columns and virtual MOs as rows."""
        matrix_file = self.nosoc_dir / 'corevirtMO_matrix_AB_4.0A_1-26.csv'
        df = self.load_csv_matrix(matrix_file)
        
        # Row indices should be virtual MOs (NOT in core_MO_range)
        core_start, core_end = self.core_mo_range
        row_indices = [int(idx) for idx in df.index]
        assert not any(core_start <= idx <= core_end for idx in row_indices), \
            f"Row indices {row_indices} should NOT be in core range"
        
        # Column headers should be core MOs
        col_headers = [int(col) for col in df.columns]
        assert all(core_start <= col <= core_end for col in col_headers), \
            f"Column headers {col_headers} not all in core range {core_start}-{core_end}"



class TestSOCRegressionAB50(TestRegressionBase):
    """
    Reference data validation for soc case (AB_5.0A).
    
    Validates that reference data files conform to constraints from config.info_examplesoc.
    """
    
    @classmethod
    def setup_class(cls):
        """Set up and load config for soc case."""
        super().setup_class()
        
        # Load config
        config_file = cls.examples_dir / 'config.info_examplesoc'
        if not config_file.exists():
            pytest.skip(f"Config file not found: {config_file}")
        
        cls.config = parse_config_file(config_file)
        
        # Parse ranges from config
        cls.atom_range_a = parse_range(cls.config['Atom_number_range_A'])
        cls.atom_range_b = parse_range(cls.config['Atom_number_range_B'])
        cls.core_mo_range = parse_range(cls.config['core_MO_range'])
        cls.atm_core = cls.config['atm_core']
    
    def test_ab50_mocore_reference_exists(self):
        """Test that AB_5.0A MOcore reference file exists."""
        mocore_file = self.soc_dir / 'resA_MOcore_AB_5.0A_25-799.csv'
        assert mocore_file.exists(), f"Reference file not found: {mocore_file}"
    
    def test_ab50_mocore_structure_and_ranges(self):
        """Test AB_5.0A MOcore has correct structure and column/row ranges."""
        mocore_file = self.soc_dir / 'resA_MOcore_AB_5.0A_25-799.csv'
        df = self.load_csv(mocore_file)
        
        # Verify metadata columns exist
        assert 'num-1' in df.columns, "Missing 'num-1' column"
        assert 'sym' in df.columns, "Missing 'sym' column"
        assert 'lvl' in df.columns, "Missing 'lvl' column"
        assert len(df) > 0, "Reference data is empty"
        
        # Extract MO columns (integers after metadata)
        mo_columns = [int(col) for col in df.columns if str(col).isdigit()]
        
        # Verify MO columns are in core_MO_range and ordered
        core_start, core_end = self.core_mo_range
        assert all(core_start <= mo <= core_end for mo in mo_columns), \
            f"MO columns {mo_columns} not all in range {core_start}-{core_end}"
        assert mo_columns == sorted(mo_columns), \
            f"MO columns {mo_columns} are not ordered"
        
        # Verify atom numbers are in Atom_number_range_A
        atom_start, atom_end = self.atom_range_a
        atom_nums = df['num-1'].values
        assert all(atom_start <= num <= atom_end for num in atom_nums), \
            f"Atom numbers {atom_nums} not all in range {atom_start}-{atom_end}"
        
        # Verify atom type matches config
        assert df['sym'].unique()[0] == self.atm_core, \
            f"Expected atom type {self.atm_core}, got {df['sym'].unique()[0]}"
    
    def test_ab50_mocore_populations_valid(self):
        """Test that MOcore populations are in valid range."""
        mocore_file = self.soc_dir / 'resA_MOcore_AB_5.0A_25-799.csv'
        df = self.load_csv(mocore_file)
        
        mo_columns = [col for col in df.columns if str(col).isdigit()]
        
        for col in mo_columns:
            values = pd.to_numeric(df[col], errors='coerce')
            assert not values.isna().any(), f"NaN in column {col}"
            assert (values >= 0).all() and (values <= 100).all(), \
                f"Invalid population range in column {col}"
    
    def test_ab50_movirt_reference_exists(self):
        """Test that AB_5.0A MOvirt reference file exists."""
        movirt_file = self.soc_dir / 'resB_MOvirt_AB_5.0A_25-799.csv'
        assert movirt_file.exists(), f"Reference file not found: {movirt_file}"
    
    def test_ab50_movirt_structure_and_ranges(self):
        """Test AB_5.0A MOvirt column headers are NOT in core_MO_range."""
        movirt_file = self.soc_dir / 'resB_MOvirt_AB_5.0A_25-799.csv'
        df = self.load_csv(movirt_file)
        
        # Extract virtual MO columns
        virtual_mo_columns = [int(col) for col in df.columns if str(col).isdigit()]
        
        # Verify virtual MOs are NOT in core_MO_range
        core_start, core_end = self.core_mo_range
        assert not any(core_start <= mo <= core_end for mo in virtual_mo_columns), \
            f"Virtual MOs {virtual_mo_columns} should NOT be in core range {core_start}-{core_end}"
    
    def test_ab50_movirt_contains_all_atoms(self):
        """Test that MOvirt rows contain all atom numbers in Atom_number_range_B."""
        movirt_file = self.soc_dir / 'resB_MOvirt_AB_5.0A_25-799.csv'
        df = self.load_csv(movirt_file)
        
        atom_start, atom_end = self.atom_range_b
        atom_nums = set(df['num-1'].values)
        expected_atoms = set(range(atom_start, atom_end + 1))
        
        assert atom_nums == expected_atoms, \
            f"Atom numbers {sorted(atom_nums)} don't match expected range {atom_start}-{atom_end}"
    
    def test_ab50_corevirt_files_exist(self):
        """Test that 8 corevirt* files exist for soc case (0 and 1 variants)."""
        expected_files = [
            'corevirtMO_matrix0_AB_5.0A_25-799.csv',
            'corevirtMO_matrix0_tspb_AB_5.0A_25-799.csv',
            'corevirtMO_matrix1_AB_5.0A_25-799.csv',
            'corevirtMO_matrix1_tspb_AB_5.0A_25-799.csv',
            'corevirt_fosc0_corr_AB_5.0A_25-799.csv',
            'corevirt_fosc1_corr_AB_5.0A_25-799.csv',
            'corevirt_foscw0_corr_AB_5.0A_25-799.csv',
            'corevirt_foscw1_corr_AB_5.0A_25-799.csv'
        ]
        for filename in expected_files:
            filepath = self.soc_dir / filename
            assert filepath.exists(), f"Reference file not found: {filepath}"
    
    def test_ab50_corevirt_matrix0_ranges(self):
        """Test that corevirtMO_matrix0 has core MOs as columns and virtual MOs as rows."""
        matrix_file = self.soc_dir / 'corevirtMO_matrix0_AB_5.0A_25-799.csv'
        df = self.load_csv_matrix(matrix_file)
        
        # Row indices should be virtual MOs (NOT in core_MO_range)
        core_start, core_end = self.core_mo_range
        row_indices = [int(idx) for idx in df.index]
        assert not any(core_start <= idx <= core_end for idx in row_indices), \
            f"Row indices {row_indices} should NOT be in core range {core_start}-{core_end}"
        
        # Column headers should be core MOs
        col_headers = [int(col) for col in df.columns]
        assert all(core_start <= col <= core_end for col in col_headers), \
            f"Column headers {col_headers} not all in core range {core_start}-{core_end}"
    
    def test_ab50_corevirt_matrix1_ranges(self):
        """Test that corevirtMO_matrix1 has core MOs as columns and virtual MOs as rows."""
        matrix_file = self.soc_dir / 'corevirtMO_matrix1_AB_5.0A_25-799.csv'
        df = self.load_csv_matrix(matrix_file)
        
        # Row indices should be virtual MOs (NOT in core_MO_range)
        core_start, core_end = self.core_mo_range
        row_indices = [int(idx) for idx in df.index]
        assert not any(core_start <= idx <= core_end for idx in row_indices), \
            f"Row indices {row_indices} should NOT be in core range {core_start}-{core_end}"
        
        # Column headers should be core MOs
        col_headers = [int(col) for col in df.columns]
        assert all(core_start <= col <= core_end for col in col_headers), \
            f"Column headers {col_headers} not all in core range {core_start}-{core_end}"


class TestPipelineRegressionNOSOC(TestRegressionBase):
    """
    Regression tests for pipeline output against nosoc reference (AB_4.0A).
    
    When a developer modifies code and runs the pipeline with the AB_4.0A toy model,
    these tests verify the output matches the known-good reference values.
    """
    
    @pytest.fixture
    def nosoc_output_dir(self, tmp_path):
        """
        Fixture for pipeline output directory.
        In practice, this would be the output from running the pipeline with AB_4.0A.
        """
        # This is a placeholder - in actual use, this would be populated by the pipeline
        return tmp_path
    
    @pytest.mark.skip(reason="Requires pipeline output to compare")
    def test_nosoc_mocore_output_matches_reference(self, nosoc_output_dir):
        """Test that nosoc MOcore pipeline output matches reference."""
        # Load reference
        ref_file = self.nosoc_dir / 'resA_MOcore_AB_4.0A_1-26.csv'
        reference = self.load_csv(ref_file)
        
        # Load output (would be generated by pipeline)
        output_file = nosoc_output_dir / 'resA_MOcore_AB_4.0A_1-26.csv'
        
        if not output_file.exists():
            pytest.skip(f"Output file not found: {output_file}")
        
        output = self.load_csv(output_file)
        
        # Compare with tolerance for numerical precision
        is_match, diff = self.compare_dataframes(reference, output, rtol=1e-5, atol=0.1)
        
        assert is_match, f"Output doesn't match reference: {diff}"
    
    @pytest.mark.skip(reason="Requires pipeline output to compare")
    def test_nosoc_corevirt_matrix_matches_reference(self, nosoc_output_dir):
        """Test that nosoc core-virtual matrix matches reference."""
        ref_file = self.nosoc_dir / 'corevirtMO_matrix_AB_4.0A_1-26.csv'
        reference = self.load_csv_matrix(ref_file)
        
        output_file = nosoc_output_dir / 'corevirtMO_matrix_AB_4.0A_1-26.csv'
        
        if not output_file.exists():
            pytest.skip(f"Output file not found: {output_file}")
        
        output = self.load_csv_matrix(output_file)
        
        # Matrix values should match exactly or within 1 count
        is_match = self.compare_matrices(reference, output, rtol=0, atol=1)
        assert is_match, "Output matrix doesn't match reference"


class TestPipelineRegressionSOC(TestRegressionBase):
    """
    Regression tests for pipeline output against soc reference (AB_5.0A).
    
    When a developer modifies code and runs the pipeline with the AB_5.0A toy model,
    these tests verify the output matches the known-good reference values.
    """
    
    @pytest.fixture
    def soc_output_dir(self, tmp_path):
        """
        Fixture for pipeline output directory.
        In practice, this would be the output from running the pipeline with AB_5.0A.
        """
        # This is a placeholder - in actual use, this would be populated by the pipeline
        return tmp_path
    
    @pytest.mark.skip(reason="Requires pipeline output to compare")
    def test_soc_mocore_output_matches_reference(self, soc_output_dir):
        """Test that soc MOcore pipeline output matches reference."""
        ref_file = self.soc_dir / 'resA_MOcore_AB_5.0A_25-799.csv'
        reference = self.load_csv(ref_file)
        
        output_file = soc_output_dir / 'resA_MOcore_AB_5.0A_25-799.csv'
        
        if not output_file.exists():
            pytest.skip(f"Output file not found: {output_file}")
        
        output = self.load_csv(output_file)
        
        is_match, diff = self.compare_dataframes(reference, output, rtol=1e-5, atol=0.1)
        assert is_match, f"Output doesn't match reference: {diff}"
    
    @pytest.mark.skip(reason="Requires pipeline output to compare")
    def test_soc_multiplicity_state0_matches_reference(self, soc_output_dir):
        """Test that soc multiplicity state 0 output matches reference."""
        ref_file = self.soc_dir / 'corevirtMO_matrix0_AB_5.0A_25-799.csv'
        reference = self.load_csv_matrix(ref_file)
        
        output_file = soc_output_dir / 'corevirtMO_matrix0_AB_5.0A_25-799.csv'
        
        if not output_file.exists():
            pytest.skip(f"Output file not found: {output_file}")
        
        output = self.load_csv_matrix(output_file)
        
        is_match = self.compare_matrices(reference, output, rtol=0, atol=1)
        assert is_match, "Output matrix0 doesn't match reference"
    
    @pytest.mark.skip(reason="Requires pipeline output to compare")
    def test_soc_multiplicity_state1_matches_reference(self, soc_output_dir):
        """Test that soc multiplicity state 1 output matches reference."""
        ref_file = self.soc_dir / 'corevirtMO_matrix1_AB_5.0A_25-799.csv'
        reference = self.load_csv_matrix(ref_file)
        
        output_file = soc_output_dir / 'corevirtMO_matrix1_AB_5.0A_25-799.csv'
        
        if not output_file.exists():
            pytest.skip(f"Output file not found: {output_file}")
        
        output = self.load_csv_matrix(output_file)
        
        is_match = self.compare_matrices(reference, output, rtol=0, atol=1)
        assert is_match, "Output matrix1 doesn't match reference"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
