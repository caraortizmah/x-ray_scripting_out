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
opt_soc="$7" #SOC option, off is 0, on is 1
out_file="$8" #orca output
exc_range="$9" #excited states range using two numbers joint by '-'

# Spectra lecture option, 1 for no corrected spectra 
if [[ ! -n ${10} ]]; then
    spectra=$((0)) #default option (corrected spectra)
else
    spectra="${10}" # default (0) corrected spectra
    if (( $spectra!=1 )); then
	 spectra=$((0))
    fi
fi

# Atom from the core space lecture option, e.g.:
# C, N, O, S, P. C is the default option 
if [[ ! -n ${11} ]]; then
    atmcore="C" #default option (Carbon atom)
else
    atmcore="${11}" # default (C)
    if [[ "${atmcore}" != "C" && "${atmcore}" != "N" && "${atmcore}" != "O" && "${atmcore}" != "S" ]]; then
	 echo "Warning: you will use an atom different as C, N, O or S."
    fi
fi

# Molecular orbital from the core space lecture option, e.g.:
# s, p. s is the default option 
if [[ ! -n ${12} ]]; then
    wavef="s" #default option (s core orbital)
else
    wavef="${12}" # default (s)
    if [[ "${wavef}" != "s" ]]; then
	 echo "Warning: you are not selecting core orbital s."
    fi
fi

# Defining zero as default option: S'=S
if (( $opt_soc!=1 )); then
	opt_soc=$((0))
fi

# Extracting information from the output

./step1.sh $MO_ini $MO_fin $opt_soc $out_file #obtaining excited states and 1s core MOs

out1_step1="popul_mo.out" #popul_mo.out comes from step1.sh
#./step2.sh $A_ini $A_fin $MO_ini $MO_fin $out1_step1 #obtaining core MOs from residue A 
./step2.sh $A_ini $A_fin $MO_ini $MO_fin $out1_step1 $atmcore $wavef #obtaining core MOs from residue A 

out_step2="resA_mo.out" #resA_mo.out comes from step2.sh
./step3.sh $MO_ini $MO_fin $out_step2 $atmcore $wavef #generating res-A core-MO population matrix 

out2_step1="exc_states_transitions.out" # exc_states_transitions.out (from step1.sh)
out3_step1="exc_states2_transitions.out" # exc_states2_transitions.out (from step1.sh)
out4_step1="exc_energies_list.out" # Energies list with root and spin number (from step1.sh)
out1_step3="resA_MOcore.out" # resA_MOcore.out (from step3.sh)
out2_step3="resA_popMO.tmp" # resA_popMO.tmp (from step3.sh)
# Generating transitions list just for the atoms involved in resA and the list of virtual
#  MO involved in these transitions
./step4.sh $out2_step1 $out1_step3 $out2_step3 $opt_soc $exc_range

# Additional step only for the SOC evaluation
if (( $opt_soc==1 )); then
	# Intermediate file (1 line below) with weight, root and spin numbers (from step4.sh)
	out1_step4="trans_st3.out"
	./step4_soc.sh $out1_step4 $out2_step1 $out3_step1 $out4_step1
fi

out2_step4="trans_st.out" # modified in step4_soc

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

#./step8.sh $out2_step1 $exc_range

./step8.sh $out2_step4 $exc_range $opt_soc

# Additional step to differentiate which 9th step to perform
if (( $spectra==0 )); then
	# Updated step9 version which only works with corrected spectra version
        ./step9_soc.sh $out2_step4 $out_file $opt_soc
else
	# Original step9 version which only works with 
	# velocity and electric dipole moment spectrum
        ./step9.sh $out2_step4 $out_file
fi

#./step9.sh exc_states.tmp $out_file

mkdir -p ${out_file}_out
mv *.out ${out_file}_out/
mv *.tmp ${out_file}_out/
mv *.csv ${out_file}_out/

