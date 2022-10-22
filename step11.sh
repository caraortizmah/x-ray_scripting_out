#!/bin/bash

# copying .csv results for each folder, after executing manager.sh, in pop_matrices folder with another name.

list="2.5 2.6 2.8 2.9 3.0 4.0 4.5 5.0 6.0 6.5 7.0 8.0 8.5 9.5 10.0 10.5"

for ii in $list
do
	jj=$(printf "%2.0f" "$(bc <<< "$ii * 10")")
	echo "Moving, from output data "$ii", the .csv results having distance "$jj" to pop_matrices"

        mv AB_${ii}A.out_out/corevirt_fosc_e_matrix.csv pop_matrices/corevirt_fosce_FY_${jj}.csv
	mv AB_${ii}A.out_out/corevirt_fosc_v_matrix.csv pop_matrices/corevirt_foscv_FY_${jj}.csv
	mv AB_${ii}A.out_out/resA_MOcore.csv pop_matrices/resA_MOcore_FY_${jj}.csv
	mv AB_${ii}A.out_out/resB_MOcore.csv pop_matrices/resB_MOcore_FY_${jj}.csv
	mv AB_${ii}A.out_out/corevirtMO_matrix.csv pop_matrices/corevirtMO_matrix_FY_${jj}.csv
	mv AB_${ii}A.out_out/corevirtMO_matrix_ts_probability.csv pop_matrices/corevirtMO_matrix_tspb_FY_${jj}.csv
done


#resa="$1"
##resb="$2"
#resab="$2"
#resab_ts="$3"
#
#namea="$(echo "${resa}" | cut -d'.' -f1)"
##nameb="$(echo "${resb}" | cut -d'.' -f1)"
#nameab="$(echo "${resab}" | cut -d'.' -f1)"
#nameab_ts="$(echo "${resab_ts}" | cut -d'.' -f1)"
#
#sed -r 's/\s+/,/g' "${resa}" > "${namea}".csv
##sed -r 's/\s+/,/g' "${resb}" > "${nameb}".csv
#sed -r 's/\s+/,/g' "${resab}" > "${nameab}".csv
#sed -r 's/\s+/,/g' "${resab_ts}" > "${nameab_ts}".csv
##three files as output from this script
