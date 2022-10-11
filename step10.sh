#!/bin/bash

#collecting data from excited states

out_file1="$1" # exc_states_transitions.out
out1_file1="$2" # original ORCA output

opt1="ABSORPTION SPECTRUM VIA TRANSITION ELECTRIC DIPOLE MOMENTS" 
opt2="ABSORPTION SPECTRUM VIA TRANSITION VELOCITY DIPOLE MOMENTS" 

#cleaning transition states file
sed -ne "/$opt1/,/^$/p" $out1_file1 > exc_fosc_electronic_dm.tmp
sed -ne "/$opt2/,/^$/p" $out1_file1 > exc_fosc_velocity_dm.tmp

st="0"

echo "STATE coreMO->virtMO ts_dipole_moment ampt_coeff. fosc_elec_dm fosc_vel_dm" > temp_states_ts.tmp
awk -v st=$st '{if($1=="STATE") st=$2; else printf(" %s %s %s %s 0.0 0.0\n", st, $1, $3, $4)}' ${out_file1} \
        | awk 'NF==6{if ($1>0 && $2!="Calculating") print $0}' >> temp_states_ts.tmp

for ii in $(awk '{print $1}' temp_states_ts.tmp | sort -u -n | uniq)
do
	fosc_edm="$(awk -v st=$ii '{if($1==st) print $4}' exc_fosc_electronic_dm.tmp)" 
	fosc_vdm="$(awk -v st=$ii '{if($1==st) print $4}' exc_fosc_velocity_dm.tmp)"
	awk -v ed=$fosc_edm -v vd=$fosc_vdm -v st=$ii '{if($1==st && $1!="STATE"){ $5=ed; $6=vd; print $0} else{ print $0}}' temp_states_ts.tmp > states_ts_fosc.tmp
	mv states_ts_fosc.tmp temp_states_ts.tmp
done

#ordered list of core MO involved from all states
lst_coremo="$(awk '$2!="coreMO->virtMO"{print $2}' temp_states_ts.tmp | cut -d'-' -f1 | sort -u -n | uniq)"
#ordered list of virtual MO involved from all states
lst_virtmo="$(awk '$2!="coreMO->virtMO"{print $2}' temp_states_ts.tmp | cut -d'>' -f2 | sort -u -n | uniq)"

echo "virt\core " $lst_coremo > corevirt_fosc_e_matrix.tmp
echo "virt\core " $lst_coremo > corevirt_fosc_v_matrix.tmp

for ii in $lst_virtmo
do

	row_val=$ii
	pos_val_e=""
	pos_val_v=""

	for jj in $lst_coremo
	do
		#transition ocurrence number
		ts_num="$(grep -n "${jj}->${ii}" temp_states_ts.tmp | wc -l)"

		#average weighted fosc electronic dipole moment (ts_dipole_moment*fosc_elec_dm)
		ls_fosc_edm="$(grep -n "${jj}->${ii}" temp_states_ts.tmp | awk '{print $3*$5}')"
		#average weighted fosc velocity dipole moment (ts_dipole_moment*fosc_vel_dm)
		ls_fosc_vdm="$(grep -n "${jj}->${ii}" temp_states_ts.tmp | awk '{print $3*$6}')"
		
		if (( $ts_num > 0)); then
			fs_e="$(echo $ls_fosc_edm | awk -v x=0 -v y=$ts_num '{while (c++<=NR) x=x+$c; print x/y}')"
			fs_v="$(echo $ls_fosc_vdm | awk -v x=0 -v y=$ts_num '{while (c++<=NR) x=x+$c; print x/y}')"
		else
			fs_e=0
			fs_v=0
		fi
		
		pos_val_e="$(echo "$pos_val_e $fs_e")"
		pos_val_v="$(echo "$pos_val_v $fs_v")"
		
	done

	echo "$row_val $pos_val_e" >> corevirt_fosc_e_matrix.tmp
	echo "$row_val $pos_val_v" >> corevirt_fosc_v_matrix.tmp
done

mv corevirt_fosc_e_matrix.tmp corevirt_fosc_e_matrix.out
mv corevirt_fosc_v_matrix.tmp corevirt_fosc_v_matrix.out
mv temp_states_ts.tmp states_corevirtMO_fosc_table.out

#three files as outputs from this script
