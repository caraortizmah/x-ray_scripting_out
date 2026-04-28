#!/bin/bash

# Setup script for X-ray Spectroscopy Pipeline
# Initializes project structure and makes scripts executable

set -e

echo "========================================="
echo "X-ray Spectroscopy Pipeline: Setup"
echo "========================================="
echo ""

# Make scripts executable
echo "[1/4] Making scripts executable..."
chmod +x src/*.sh 2>/dev/null || true
chmod +x bin/*.sh 2>/dev/null || true
chmod +x bin/*.py 2>/dev/null || true
echo "+ Scripts transformed into executables"

# Create necessary directories
echo ""
echo "[2/4] Setting up directory structure..."
for dir in input output src tests docs; do
    if [ -d "$dir" ]; then
        echo "+ $dir directory exists"
    else
        mkdir -p "$dir"
        echo "+ Created $dir directory"
    fi
done

# Add .gitkeep files to maintain empty directories
touch input/.gitkeep 2>/dev/null || true
touch output/.gitkeep 2>/dev/null || true
echo "+ Directory structure ready"

# Copy original shell scripts to src/ if not already there
echo ""
echo "[3/4] Organizing shell scripts..."
SHELL_SCRIPTS=(manager.sh helper_man.sh overall.sh step1.sh step2.sh \
step3.sh step4.sh step4_soc.sh step5.sh step6.sh step7.sh step8.sh \
step9.sh step9_soc.sh step10.sh step11.sh)
for script in "${SHELL_SCRIPTS[@]}"; do
    if [ -f "$script" ] && [ ! -f "src/$script" ]; then
        cp "$script" "src/$script"
        echo "+ Copied $script to src/"
    fi
done

# Check Python installation
echo ""
echo "[4/4] Checking Python environment..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    echo "+ Python $PYTHON_VERSION found"
    
    # Check if xas_qmol_parser package is importable
    if python3 -c "import sys; sys.path.insert(0, '.'); from xas_qmol_parser import ConfigManager" 2>/dev/null; then
        echo "+ Python package xas_qmol_parser is ready"
    else
        echo "! Warning: Could not import xas_qmol_parser package"
        echo "  Make sure to install dependencies if needed"
    fi
else
    echo "! Python 3 not found - some features will not work"
fi

echo ""
echo "========================================="
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Verify config.info settings"
echo "  2. Run: ./bin/check_environment.sh"
echo "  3. Run: ./helper_man.sh --validate-only"
echo "  4. Run: ./helper_man.sh"
echo "========================================="
