#!/bin/bash

# MO_ini and MO_fin are the range of core MO corresponding
#  to C 1s, it is necessary to adapt it for N and O
# out_file is the output from the PNO-DFTROCIS
#  X-ray absorption calculation in ORCA

MO_ini="$1" #first 1s core MO
MO_fin="$2" #last 1s core MO
out_file="$3" #orca output

#extracting information from the output

#extracting excited states

popul_ini="$(grep -n "LOEWDIN REDUCED ORBITAL POPULATIONS PER MO" $out_file | cut -d':' -f1)"
popul_fin="$(grep -n "MAYER POPULATION ANALYSIS" $out_file | cut -d':' -f1)"

exc_ini="$(grep -n "Eigenvectors of ROCIS calculation:" $out_file | cut -d':' -f1)"
exc_fin="$(grep -n "Calculating transition densities   ...Done" $out_file | cut -d':' -f1)"


awk -v x=$exc_ini -v y=$exc_fin 'NR==x, NR==y {printf "%s\n", $0}' $out_file > exc_states_transitions.out

#extracting loewdin MO population

awk -v x=$popul_ini -v y=$popul_fin 'NR==x, NR==y {printf "%s\n", $0}' $out_file > popul_mo.out

sed -n "/  $MO_ini  /,/  $MO_fin  /p" popul_mo.out > resA_mo.out
sed -n "/  $MO_fin  /,/^$/p" popul_mo.out >> resA_mo.out

#three files as output from this script (exc_states_transitions.out, popul_mo.out, resA_mo.out)
