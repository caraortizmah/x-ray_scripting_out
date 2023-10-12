#!/bin/bash

# Creating core/virt MO matrix as a function of the total transition state ocurrences

out2_file1="$1" # exc_states_transitions.out
arg="$2"

# Cleaning transition states file by a defined range of excited states
if (($arg=="none")); then
        sed -ne '/STATE   1 /,$ p' $out2_file1 > exc_states.tmp
else
	ex_ini="$(echo $arg | cut -d'-' -f1)"
	ex_fin="$(echo $arg | cut -d'-' -f2)"
	sed -ne "/$(echo STATE $ex_ini | awk '{printf("%s%4d ",$1,$2)}')/,/$(echo STATE $ex_fin | awk '{printf("%s%4d",$1,$2+1)}')/p" exc_states_transitions.out  > exc_states.tmp
fi

#sed -ne "/STATE   1 /,/$(echo $var1 $var3 | awk '{printf("%s%4d",$1,$2+1)}')/p" exc_states_transitions.out  > exc_states.tmp

#sed -ne '/STATE   1 /,$ p' $out2_file1 > exc_states.tmp
#extracting just rows containing core to virtual MO transitions
awk 'NF { if ( $1 != "STATE" && $1 != "Calculating"){ print $0 } }' exc_states.tmp > exc_states.tmp2

#ordered list of core MO involved from all states
lst_coremo="$(awk '{print $1}' exc_states.tmp2 | cut -d'-' -f1 | sort -u -n | uniq)"
#ordered list of virtual MO involved from all states
lst_virtmo="$(awk '{print $1}' exc_states.tmp2 | cut -d'>' -f2 | sort -u -n | uniq)"

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
		#transition ocurrence number
		ts_num="$(grep -n " ${jj}->${ii} " exc_states.tmp2 | wc -l)"

		pos_val="$(echo "$pos_val $ts_num")"

		#total transition ocurrence states probability`
		list_ts_p="$(grep -n " ${jj}->${ii} " exc_states.tmp2 | awk '{print $4}')"
		
		if (( $ts_num > 0)); then
			#ts_p="$(echo $list_ts_p | awk -v x=0 -v y=$ts_num '{while (c++<=NR) x=x+$c; print x/y}')"
			ts_p="$(echo $list_ts_p | awk -v x=0 -v y=0 '{while (c++<=NF){ x=x+($c*$c); y=y+$c}; print x/y}')"
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
#four files as outputs from this script (corevirtMO_matrix.out, corevirtMO_matrix_ts_probability.out,
# corevirtMO_matrix.csv, corevirtMO_matrix_ts_probability.csv)
