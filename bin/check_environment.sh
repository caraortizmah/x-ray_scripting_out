#!/bin/bash

# Environment checking script for X-ray spectroscopy pipeline
# Verifies that all required dependencies and tools are available

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Function to print colored status
print_status() {
    local status=$1
    local message=$2
    
    if [ "$status" = "+" ]; then
        echo -e "${GREEN}${status}${NC} ${message}"
    elif [ "$status" = "x" ]; then
        echo -e "${RED}${status}${NC} ${message}"
        ERRORS=$((ERRORS + 1))
    elif [ "$status" = "!" ]; then
        echo -e "${YELLOW}${status}${NC} ${message}"
        WARNINGS=$((WARNINGS + 1))
    fi
}

echo "========================================="
echo "X-ray Spectroscopy Pipeline: Environment Check"
echo "========================================="
echo ""

# Check Python version
echo "[1/6] Checking Python..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
    MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)
    
    if [ "$MAJOR" -ge 3 ] && [ "$MINOR" -ge 6 ]; then
        print_status "+" "Python $PYTHON_VERSION found"
    else
        print_status "x" "Python 3.6+ required, found $PYTHON_VERSION"
    fi
else
    print_status "x" "Python 3 not found"
fi

# Check required shell commands
echo ""
echo "[2/6] Checking required shell commands..."
REQUIRED_COMMANDS=("awk" "grep" "sed" "cut" "tr" "sort" "uniq" "wc" "head" "tail")

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if command -v "$cmd" &> /dev/null; then
        print_status "+" "$cmd found"
    else
        print_status "x" "$cmd not found (required)"
    fi
done

# Check optional tools
echo ""
echo "[3/6] Checking optional tools..."
OPTIONAL_COMMANDS=("git" "python3-pytest" "shellcheck")

for cmd in "${OPTIONAL_COMMANDS[@]}"; do
    # Handle python package names
    if [ "$cmd" = "python3-pytest" ]; then
        if python3 -c "import pytest" 2>/dev/null; then
            print_status "+" "pytest module found"
        else
            print_status "!" "pytest not installed (optional)"
        fi
    elif command -v "$cmd" &> /dev/null; then
        print_status "+" "$cmd found"
    else
        print_status "!" "$cmd not found (optional)"
    fi
done

# Check script permissions
echo ""
echo "[4/6] Checking script permissions..."
echo $PWD
SCRIPTS=("manager.sh" "step1.sh" "step2.sh" "step3.sh" "step4.sh"
"step4_soc.sh" "step5.sh" "step6.sh" "step7.sh" "step8.sh" 
"step9.sh" "step9_soc.sh" "migrator.sh")

for script in "${SCRIPTS[@]}"; do
    if [ -f "src/$script" ]; then
        if [ -x "src/$script" ]; then
            print_status "+" "$script is executable"
        else
            print_status "!" "$script is not executable"
            echo "      Run: chmod +x $script"
        fi
    else
        print_status "!" "src/$script not found"
    fi
done

# Check required directories
echo ""
echo "[5/6] Checking directory structure..."
DIRS=("input" "output" "src" "tests" "docs")

for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        if [ -w "$dir" ]; then
            print_status "+" "$dir directory exists and is writable"
        else
            print_status "x" "$dir exists but is not writable"
        fi
    else
        print_status "!" "$dir directory not found"
    fi
done

# Check ORCA compatibility
echo ""
echo "[6/6] Checking ORCA compatibility..."
if [ -f "config.info" ]; then
    ORCA_FILE=$(grep "orca_output" config.info | cut -d'=' -f2 | tr -d ' ' || true)
    INPUT_PATH=$(grep "input_path" config.info | cut -d'=' -f2 | tr -d ' ' || true)
    OUTPUT_PATH=$(grep "output_path" config.info | cut -d'=' -f2 | tr -d ' ' || true)
    if [ -z "$ORCA_FILE" ]; then
        print_status "!" "orca_output not set in config.info"
    elif [ ! -e "$INPUT_PATH" ]; then
        print_status "!" "Input path $INPUT_PATH does not exist"
    elif [ ! -e "$OUTPUT_PATH" ]; then
        print_status "!" "Output path $OUTPUT_PATH does not exist"
    elif [ -f "$INPUT_PATH/$ORCA_FILE" ]; then
        # Check ORCA version in file
        if grep -q "ORCA TERMINATED NORMALLY" "$INPUT_PATH/$ORCA_FILE"; then
            ORCA_VERSION=$(grep "Version" "$INPUT_PATH/$ORCA_FILE" | head -1 || true)
            print_status "+" "ORCA output file found"
            ORCA_version_number=$(echo "$ORCA_VERSION" | tr -s ' ' | cut -d' ' -f4 || true)
            echo "      Version info: $ORCA_version_number"
            if [ "$(echo "$ORCA_version_number" | cut -d'.' -f1 || true)" -ge 6 ]; then
                print_status "!" "ORCA version $ORCA_version_number may not be fully compatible"
            else
                print_status "+" "ORCA version $ORCA_version_number appears compatible"
            fi
        else
            print_status "x" "ORCA file does not appear to be valid"
        fi
    else
        print_status "!" "ORCA output file $ORCA_FILE not found in $INPUT_PATH"
        echo "Hint:   read docs/quickstart.md to set up config.info and necessary files prior to run"
    fi
    EXT_FILE=$(grep "external_MO_file" config.info | cut -d'=' -f2 | tr -d ' ' || true)
    if [ -z "$EXT_FILE" ]; then
        print_status "!" "external_MO_file not set in config.info "$ORCA_FILE\
        " may be used as external MO file, which may cause issues"
    elif [ ! -f "$INPUT_PATH/$EXT_FILE" ]; then
        print_status "!" "external_MO_file $EXT_FILE not found in $INPUT_PATH"
        echo "Hint:   read docs/quickstart.md to set up config.info and necessary files prior to run"
    elif grep -q "NormalPrint" "$INPUT_PATH/$EXT_FILE" && \
    grep -q "LOEWDIN REDUCED ORBITAL POPULATIONS PER MO" "$INPUT_PATH/$EXT_FILE"; then
        print_status "+" "Loewdin population analysis appears to be found in NormalPrint \
        format in "$EXT_FILE
        if [ "$EXT_FILE" == "$ORCA_FILE" ]; then
            print_status "+" "external_MO_file is set to ORCA output file"
        fi
    else
        print_status "!" "Loewdin population analysis appears to not be found in "$EXT_FILE
    fi
else
    print_status "!" "config.info not found"
fi

# Summary
echo ""
echo "========================================="
echo "Summary:"
echo "  Errors: $ERRORS"
echo "  Warnings: $WARNINGS"
echo "========================================="

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}Please fix the errors above before running the pipeline${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}Warnings found, but pipeline may still work${NC}"
    exit 0
else
    echo -e "${GREEN}All checks passed! Environment is ready.${NC}"
    exit 0
fi
