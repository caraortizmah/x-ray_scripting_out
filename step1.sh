#!/bin/bash

# MO_ini and MO_fin are the range of core MO corresponding
#  to C 1s, it is necessary to adapt it for N and O
# out_file is the output from the PNO-DFTROCIS
#  X-ray absorption calculation in ORCA

MO_ini="$1" # first 1s core MO
MO_fin="$2" # last 1s core MO
opt_soc="$3" # multiplicity and SOC option, default is 0 (S'=S), 1 (S'=S+1 including SOC) 
out_file="$4" # orca output
ext_file="$5" # external file for MO population (optional)

#zero: default option S'=S
exc_ini="$(grep -n "Eigenvectors of ROCIS calculation:" $out_file | cut -d':' -f1)"

if (( $opt_soc==0 )); then
	exc_fin="$(grep -n "Calculating transition densities" $out_file | cut -d':' -f1)"
        
	awk -v x=$exc_ini -v y=$exc_fin 'NR==x, NR==y {printf "%s\n", $0}' $out_file > exc_states_transitions.out
#one: higher multiplicity S'=S+1	
else # $opt_soc==1
	
	exc_fin="$(grep -n "HIGHER MULTIPLICITY CI" $out_file | cut -d':' -f1)"
	exc_ini2="$(grep -n "Eigenvectors of ROCIS calculation with S'=S+1:" $out_file | cut -d':' -f1)"
	exc_fin2="$(grep -n "Calculating transition densities   ...Done" $out_file | cut -d':' -f1)"

	awk -v x=$exc_ini -v y=$exc_fin 'NR==x, NR==y {printf "%s\n", $0}' $out_file > exc_states_transitions.out
	awk -v x=$exc_ini2 -v y=$exc_fin2 'NR==x, NR==y {printf "%s\n", $0}' $out_file > exc_states2_transitions.out
	
	head -n -3 exc_states_transitions.out > trans_tmp
	mv trans_tmp exc_states_transitions.out
#bonus: spin-orbit coupling (SOC)
	exc_ini3="$(grep -n "Eigenvectors of SOC calculation:" $out_file | cut -d':' -f1)"
	exc_fin3="$(grep -n "Excitation energies (after SOC)" $out_file | cut -d':' -f1)"
	exc_ini4="$(grep -n "Excitation energies" $out_file | awk '{if(FNR==1) print $0}' | cut -d':' -f1)"
	exc_fin4="$(grep -n "ROCIS-EXCITATION SPECTRA" $out_file | awk '{if(FNR==1) print $0}' | cut -d':' -f1)"
	awk -v x=$exc_ini3 -v y=$exc_fin3 'NR==x, NR==y {printf "%s\n", $0}' $out_file > exc_states3_transitions.out
	awk -v x=$exc_ini4 -v y=$exc_fin4 'NR==x, NR==y {printf "%s\n", $0}' $out_file > exc_energies_list.out
	head -n -3 exc_states3_transitions.out > trans_tmp
	mv trans_tmp exc_states3_transitions.out


fi

#extracting loewdin MO population

popul_ini="$(grep -n "LOEWDIN REDUCED ORBITAL POPULATIONS PER MO" $ext_file | cut -d':' -f1)"
popul_fin="$(grep -n "MAYER POPULATION ANALYSIS" $ext_file | cut -d':' -f1)"

awk -v x=$popul_ini -v y=$popul_fin 'NR==x, NR==y {printf "%s\n", $0}' $ext_file > popul_mo.out

sed -n "/  $MO_ini  /,/  $MO_fin  /p" popul_mo.out > resA_mo.out
sed -n "/  $MO_fin  /,/^$/p" popul_mo.out >> resA_mo.out

# Option 0: S'=S
#  Three files as outputs from this script (exc_states_transitions.out, popul_mo.out, resA_mo.out)
# Option 1: S'=S+1 and SOC
#  Six files as outputs from this script (exc_states_transitions.out, exc_states2_transitions.out,
#  exc_states3_transitions.out, exc_energies_list.out, popul_mo.out, resA_mo.out)
