#!/bin/bash

# Creating core/virt MO matrix as a function of the total transition state ocurrences

out2_file1="$1" # trans_st.out
arg="$2" # Excited states range
opt_soc="$3" # SOC option

# Extracting just rows containing core to virtual MO transitions
awk 'NF { if ( $1 != "STATE" && $1 != "Calculating"){ print $0 } }' $out2_file1 > exc_states.tmp2

#ordered list of core MO involved from all states
lst_coremo="$(awk '{print $1}' exc_states.tmp2 | cut -d'-' -f1 | sort -nu | uniq)"
#ordered list of virtual MO involved from all states
lst_virtmo="$(awk '{print $1}' exc_states.tmp2 | cut -d'>' -f2 | sort -nu | uniq)"

#cols_n="$(echo $lst_coremo | wc -w)" #number of columns in a "file"

echo "virt\core " $lst_coremo > corevirtMO_matrix.tmp
echo "virt\core " $lst_coremo > corevirtMO_matrix_ts_probability.tmp

#echo $lst_virtmo | awk '{ while (c++<NF) printf "%s\n", $c}' | awk -v col=${cols_n} 'NF { while (c++<col) s=s " 0.0 "; printf "%s %s\n", $0, s}' >> corevirtMO_matrix.tmp

for ii in $lst_virtmo
do

	row_val=$ii
	pos_val=""
	pos_val_ts=""

	for jj in $lst_coremo
	do
		# Transition ocurrence number
		ts_num="$(grep -n " ${jj}->${ii} " exc_states.tmp2 | wc -l)"

		pos_val="$(echo "$pos_val $ts_num")"

		# Total transition ocurrence states probability
                if (( $opt_soc!=1 )); then
			# There is just one weight when option is S'=S
			list_ts_p="$(grep -n " ${jj}->${ii} " exc_states.tmp2 | awk '{print $4}')"
		else
			# Multiplication by $6 (an additional weight) that corresponds to
			#  the weight from the SOC evaluation
			list_ts_p="$(grep -n " ${jj}->${ii} " exc_states.tmp2 | awk '{print $4*$6}')"
                fi
		
		if (( $ts_num > 0)); then
			# Average
			#ts_p="$(echo $list_ts_p | awk -v x=0 -v y=$ts_num '{while (c++<=NR) x=x+$c; print x/y}')"
			# Weighted average
			ts_p="$(echo $list_ts_p | awk -v x=0 -v y=0 '{while (c++<=NF){ x=x+($c*$c); y=y+$c}; if(y==0){print y}else{print x/y}}')"
		else
			ts_p=0
		fi
		
		pos_val_ts="$(echo "$pos_val_ts $ts_p")"
		#="$(echo corevirtMO_matrix.tmp | awk -v ii="$ii" -v jj="$jj" 'a[$1]==ii{for (c=1;c<=NF;c++) { if ($c == jj) { print c } }}')"

	done

	echo "$row_val $pos_val" >> corevirtMO_matrix.tmp
	echo "$row_val $pos_val_ts" >> corevirtMO_matrix_ts_probability.tmp
done

mv corevirtMO_matrix.tmp corevirtMO_matrix.out
mv corevirtMO_matrix_ts_probability.tmp corevirtMO_matrix_ts_probability.out
sed -r 's/\s+/,/g' corevirtMO_matrix.out > corevirtMO_matrix.csv
sed -r 's/\s+/,/g' corevirtMO_matrix_ts_probability.out > corevirtMO_matrix_ts_probability.csv

rm exc_states.tmp2
head -n -1 exc_states.tmp > test2
mv test2 exc_states.tmp

# Four files as outputs from this script (corevirtMO_matrix.out, corevirtMO_matrix_ts_probability.out,
#  corevirtMO_matrix.csv, corevirtMO_matrix_ts_probability.csv)
