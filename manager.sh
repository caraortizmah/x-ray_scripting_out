#!/bin/bash

# A_ini and A_fin are the atom range that represents the
#  residue of interest (res A) as occupied core MO
# B_ini and B_fin are the atom range that represents the
#  residue of interest (res B) as virtual MO
# MO_ini and MO_fin are the range of core MO corresponding
#  to C 1s, it is necessary to adapt it for N and O
# out_file is the output from the PNO-DFTROCIS
#  X-ray absorption calculation in ORCA

A_ini="$1" #first atom number for residue A
A_fin="$2" #last  atom number for residue A
B_ini="$3" #first atom number for residue B
B_fin="$4" #last atom number for residue B
MO_ini="$5" #first 1s core MO
MO_fin="$6" #last 1s core MO
out_file="$7" #orca output
exc_range="$8" #excited states range using two numbers joint by '-'

# defining zero as default option: S'=S
opt_soc=$((0))
if (( $opt_soc!=1 && $opt_soc!=2 )); then
	opt_soc=$((0))
fi

# extracting information from the output

./step1.sh $MO_ini $MO_fin $opt_soc $out_file #obtaining excited states and 1s core MOs

out1_step1="popul_mo.out" #popul_mo.out comes from step1.sh
./step2.sh $A_ini $A_fin $MO_ini $MO_fin $out1_step1 #obtaining core MOs from residue A 

out_step2="resA_mo.out" #resA_mo.out comes from step2.sh
./step3.sh $MO_ini $MO_fin $out_step2 #generating res-A core-MO population matrix 

out2_step1="exc_states_transitions.out" # exc_states_transitions.out comes from step1.sh
out1_step3="resA_MOcore.out" #resA_MOcore.out comes from step3.sh
out2_step3="resA_popMO.tmp" #resA_popMO.tmp comes from step3.sh
# generating transitions list just for the atoms involved in resA and the list of virtual
#  MO involved in these transitions
./step4.sh $out2_step1 $out1_step3 $out2_step3 $exc_range

out1_step4="virt_MO.tmp"
./step5.sh $B_ini $B_fin $out1_step1 $out1_step4

out1_step5="resB_mo.out" #resA_MOcore.out comes from step3.sh
out2_step5="resA_popMO.tmp" #resA_popMO.tmp comes from step3.sh
# generating transitions list just for the atoms involved in resA and the list of virtual
#  MO involved in these transitions

out1_step6="resB_mo.out"
./step6.sh $out1_step6

#exc_states_transitions.out
out1_step7="resB_collapsedMO.out"
./step7.sh $out1_step4 $out1_step7

./step8.sh $out2_step1 $exc_range

./step9.sh exc_states.tmp $out_file

mkdir -p ${out_file}_out
mv *.out ${out_file}_out/
mv *.tmp ${out_file}_out/
mv *.csv ${out_file}_out/

