#!/bin/bash

out_file="$1" #ORCA output file
ext_file="$2" #Loewdin MO population file (optional, default same as out_file)
input_path="$3" #path of $out_file and $ext_file
output_path="$4" #path of the results

#temporary directory for the execution of the scripts
tmp_dir_exe=${output_path}"/tmp_last_execution"

# create temporary directory
mkdir -p ${tmp_dir_exe}

# copy input files to temporary directory
cp ${input_path}/${out_file} ${tmp_dir_exe}/
cp ${input_path}/${ext_file} ${tmp_dir_exe}/

# Change to script directory - allows calling from anywhere
cd "$(dirname "$0")" || exit 1

# copy scripts to temporary directory
cp manager.sh ${tmp_dir_exe}/
cp step*.sh ${tmp_dir_exe}/
