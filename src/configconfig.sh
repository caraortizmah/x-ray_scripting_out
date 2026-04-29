#!/bin/bash

# This script just makes sense in the context of testing the pipeline.
# This is not a general purpose script.
# Only for developers: read /test/tester.sh for more context of how 
#  this script is used and what arguments uses.

# This script reads the config.info (${1}) file and prepares the input and output 
#  folders according to the path received in the argument ${2}.

# Option for absent parameters:

if [[ ! -n "${2}" ]]; then
    echo "The path is not detected."
    echo "ERROR: Something could go wrong in /test/tester.sh, please check!"
    exit 1
else
    if [[ ! -d "${2}" ]]; then
        echo "The specified path does not exist. Please check and try again."
        echo "ERROR: Something could go wrong in /test/tester.sh, please check!"
        exit 1
    else
        input_path="${2}/input" # input path
        output_path="${2}/output" # output path
    fi
fi

if [[ ! -f ${1} ]]; then
    echo "ERRORr: config.info file does not exist or is not detected."
    echo "ERROR: Something could go wrong in /test/tester.sh, please check!"
    exit 1
else
    config_info="${1}" # name of the config file (single word without extensions)
fi

if ! grep -q "input_path             =" "${config_info}"; then
    echo "ERROR: Incorrect format of the input_path in config.info file: ${config_info}" >&2
    exit 1
else
    if ! grep -q "output_path            =" "${config_info}"; then
        echo "ERROR: Incorrect format of the output_path in config.info file: ${config_info}" >&2
        exit 1
    else
        sed -i "/input_path             =/c\input_path             = ${input_path}" ${config_info}
        sed -i "/output_path            =/c\output_path            = ${output_path}" ${config_info}
    fi
fi
