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

# Lecture of Loewdin MO population as external file:
# 
if [[ ! -n ${13} ]]; then
    ext_file="${out_file}" #default option same out_file
else
    ext_file="${13}" # new file only for Loewdin population
fi

# Lecture of input file path (ORCA(s) output(s))
# 
if [[ ! -n ${14} ]]; then
    echo "Reading excited-state results from "${out_file}" and "
    echo "reading Loewdin molecular orbital population from "${ext_file}
    echo " in the same pipeline path"
else
    input_path="${14}" # new directory path
    echo "Reading excited-state results from "${out_file}" and "
    echo "reading Loewdin molecular orbital population from "${ext_file}
    echo " in the following path: "${input_path}
    cp ${input_path}/${out_file} .
    cp ${input_path}/${ext_file} .
fi

# Defining zero as default option: S'=S
if (( $opt_soc!=1 )); then
	opt_soc=$((0))
fi

# Extracting information from the output

./step1.sh $MO_ini $MO_fin $opt_soc $out_file $ext_file #obtaining excited states and 1s core MOs

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

out1_step4="virt_MO.tmp"
./step5.sh $B_ini $B_fin $out1_step1 $out1_step4

out2_step5="resA_popMO.tmp" # resA_popMO.tmp comes from step3.sh
# generating transitions list just for the atoms involved in resA and the list of virtual
#  MO involved in these transitions

out1_step5="resB_mo.out" # resA_MOcore.out comes from step3.sh
./step6.sh $out1_step5

#exc_states_transitions.out
out1_step7="resB_collapsedMO.out"
./step7.sh $out1_step4 $out1_step7


# Conditional step only for SOC option
if (( $opt_soc!=1 )); then

        out2_step4="trans_st.out"
        ./step8.sh $out2_step4 $exc_range 0 # no soc option by default

        # Original step9 version which only works with 
        # velocity and electric dipole moment spectrum
        
        ./step9.sh $out2_step4 $out_file

else
	# soc option: both multiplicities considered
        
	for ii in 0 1 # repeating same process for multiplicity 0 and 1
	do
		if [[ -f "trans${ii}_st.out" ]]; then
			# It can be the case when excited state does not have one of the
			# multiplicities
		        out2_step4="trans${ii}_st.out"
                        ./step8.sh $out2_step4 $exc_range $opt_soc
	                mv corevirtMO_matrix.out corevirtMO_matrix${ii}.out
	                mv corevirtMO_matrix_ts_probability.out corevirtMO_matrix_ts_probability${ii}.out
	                mv corevirtMO_matrix.csv corevirtMO_matrix${ii}.csv
	                mv corevirtMO_matrix_ts_probability.csv corevirtMO_matrix_ts_probability${ii}.csv
	
	                # Additional step to differentiate which 9th step to perform
                        if (( $spectra==0 )); then
                        	# Updated step9 version which only works with corrected spectra version
                                ./step9_soc.sh $out2_step4 $out_file $opt_soc
                        fi
                        mv corevirt_fosc_corr_matrix.csv corevirt_fosc_corr_matrix${ii}.csv
                        mv corevirt_foscw_corr_matrix.csv corevirt_foscw_corr_matrix${ii}.csv
		fi
	done
	#mv corevirtMO_matrix.out corevirtMO_matrix0.out
	#mv corevirtMO_matrix_ts_probability.out corevirtMO_matrix_ts_probability0.out
	#mv corevirtMO_matrix.csv corevirtMO_matrix0.csv
	#mv corevirtMO_matrix_ts_probability.csv corevirtMO_matrix_ts_probability0.csv
        
fi

# END PROGRAM

# Organizing outputs to be read in the next post processing step

mkdir -p ${out_file}_out
mv *.out ${out_file}_out/
mv *.tmp ${out_file}_out/
mv *.csv ${out_file}_out/

suff=".out"
pop_name=${out_file/%$suff}

mkdir -p pop_matrices
folder2=${out_file}"_csv"
mkdir -p pop_matrices/${folder2}
sufff=$exc_range

cp ${out_file}_out/resA_MOcore.csv pop_matrices/${folder2}/resA_MOcore_${pop_name}_${sufff}.csv
cp ${out_file}_out/resB_MOcore.csv pop_matrices/${folder2}/resB_MOvirt_${pop_name}_${sufff}.csv

if (( $opt_soc!=1 )); then

	cp ${out_file}_out/corevirtMO_matrix.csv pop_matrices/${folder2}/corevirtMO_matrix_${pop_name}_${sufff}.csv 2>/dev/null
        cp ${out_file}_out/corevirtMO_matrix_ts_probability.csv pop_matrices/${folder2}/corevirtMO_matrix_tspb_${pop_name}_${sufff}.csv 2>/dev/null
	cp ${out_file}_out/corevirt_fosc_e_matrix.csv pop_matrices/${folder2}/corevirt_fosc_${pop_name}_${sufff}.csv 2>/dev/null
	cp ${out_file}_out/corevirt_fosc_we_matrix.csv pop_matrices/${folder2}/corevirt_foscw_${pop_name}_${sufff}.csv 2>/dev/null

else
	
	for ii in 0 1
	do
		cp ${out_file}_out/corevirtMO_matrix${ii}.csv pop_matrices/${folder2}/corevirtMO_matrix${ii}_${pop_name}_${sufff}.csv 2>/dev/null
                cp ${out_file}_out/corevirtMO_matrix_ts_probability${ii}.csv pop_matrices/${folder2}/corevirtMO_matrix${ii}_tspb_${pop_name}_${sufff}.csv 2>/dev/null

		# Additional step only for the SOC evaluation
		cp ${out_file}_out/corevirt_fosc_corr_matrix${ii}.csv pop_matrices/${folder2}/corevirt_fosc${ii}_corr_${pop_name}_${sufff}.csv 2>/dev/null
	        cp ${out_file}_out/corevirt_foscw_corr_matrix${ii}.csv pop_matrices/${folder2}/corevirt_foscw${ii}_corr_${pop_name}_${sufff}.csv 2>/dev/null
	done

fi

# Lecture of output file path (Pipeline results)
# 
if [[ ! -n ${15} ]]; then
    echo "The total of the results are in the folder "${out_file}"_out/ in the same pipeline path" 
    echo "A reduced version of the results for jupyter-notebook analysis are in the folder pop_matrices in the same pipeline path"
else
    output_path="${15}" # new directory path
    if [[ -d "$output_path/${out_file}_out/" ]]; then
        echo "Avoiding replacement files: Raw results will remain in " ${PWD}
        echo "Due to the fact that the path "$output_path/${out_file}"_out/ already exists"
        #mv ${out_file}_out/*.* $output_path/${out_file}_out/
    else
        echo "Moving results to "$output_path
        mv ${out_file}_out $output_path/
    fi

    echo "A reduced version of the results for jupyter-notebook analysis are in the folder pop_matrices in the path:"
    echo $output_path"/pop_matrices/"${folder2}"/"
    mkdir -p $output_path/pop_matrices
    if [[ -d "$output_path/pop_matrices/${folder2}" ]]; then
        mv pop_matrices/${folder2}/*.* $output_path/pop_matrices/${folder2}/
    else
        mv pop_matrices/${folder2} $output_path/pop_matrices/
    fi
fi

echo "Pipeline run terminated"
