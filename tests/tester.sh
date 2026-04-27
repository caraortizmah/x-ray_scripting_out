#!/bin/bash

# Please read documentation ../docs/data_processing_tests.md
# and regression_testing_examples.md for more context of 
# this script

# This script automates a two-step process, which is a file
#  preparation prior to running the pipeline

# The script does the following:
# 1) Copying the orca output and config.info files from examples/ 
#    to input/ folder of the pipeline
# 2) Running the pipeline
# 3) Copying the csv data from output/pop_matrices/ 
#    to output/

# Default option for absent parameters:
if [[ ! -n ${1} ]]; then
    echo "The name of the test is required. \
    check data_processing_tests.md for more context."
    exit 1
else
    test_name="${1}" # name of the test (single word without extensions)
fi

if [[ ! -n "${2}" ]]; then
    echo "The orca output file is required. \
    Check examples/ path and try again."
    exit 1
else
    if [[ ! -f "examples/${2}" ]]; then
        echo "The specified orca output file does not exist. \
        please check examples/ path and try again."
        exit 1
    fi
    orca_output="$2" #orca output file (with .out extension)
fi

if [[ ! -n ${3} ]]; then
    config_info="config.info" #default option (current config.info)
else
    config_info="${3}" #config.info file (with .info extension)
fi

# Prepare pipeline inputs (orca output and config.info)
cp examples/${orca_output} input/
cp examples/${config_info} config.info 
# Run pipeline, e.g. with nosoc toy model (AB_4.0A)
./bin/helper_man.py
# copy or move the csv data 
cp -r output/pop_matrices/${orca_output}_csv output/${test_name}
# inside ${test_name} (e.g. ab40_test) the 6 csv files should be found
