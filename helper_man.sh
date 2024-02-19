#!/bin/bash

# Checking config.info file
file="config.info"
if [[ -f "${file}" ]]; then
	echo "Reading config.info"
else
	echo "File config.info does not exit, then helper manager script cannot work."
	echo "Read the documentation for more information."
	exit 1
fi

# Reading mandatory flags
flag="$(grep "Atom_number_range_A" $file | cut -d'=' -f2)"
A_ini="$(echo $flag | cut -d'-' -f1)"
A_fin="$(echo $flag | cut -d'-' -f2)"
flag="$(grep "Atom_number_range_B" $file | cut -d'=' -f2)"
B_ini="$(echo $flag | cut -d'-' -f1)"
B_fin="$(echo $flag | cut -d'-' -f2)"
flag="$(grep "core_MO_range" $file | cut -d'=' -f2)"
MO_ini="$(echo $flag | cut -d'-' -f1)"
MO_fin="$(echo $flag | cut -d'-' -f2)"
exc_range="$(grep "exc_state_range" $file | cut -d'=' -f2)"
opt_soc="$(grep "soc_option" $file | cut -d'=' -f2)"
out_file="$(grep "orca_output" $file | cut -d'=' -f2)"
# Reading optional flags
spectra="$(grep "spectra_option" $file | cut -d'=' -f2)"
ext_file="$(grep "external_MO_file" $file | cut -d'=' -f2)"
atm_core="$(grep "atm_core" $file | cut -d'=' -f2)"
wavef="$(grep "wave_f_type" $file | cut -d'=' -f2)"

# Checking the existence of the mandatory flags
if [[ -z "$A_ini" || -z "$A_fin" || -z "$B_ini" || -z "$B_fin" || \
	-z "$MO_ini" || -z "$MO_fin" || -z "$exc_range" || \
	-z "$opt_soc" || -z "$out_file" ]]; then
	echo "One or more mandatory flags are not written in config.info."
	echo "Read the documentation for more information."
	exit 1
fi

echo "./manager "$A_ini" "$A_fin" "$B_ini" "$B_fin" "$MO_ini" "$MO_fin" "$opt_soc" "\
	$out_file" "$exc_range" "$spectra" "$atm_core" "$wavef" "$ext_file
exit 0
