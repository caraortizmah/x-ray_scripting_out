#!/bin/bash

# MO_ini and MO_fin are the range of core MO corresponding
#  to C 1s, it is necessary to adapt it for N and O
# out_file is the core MO population in the specific format
#  for the residue A created previously in the step2.sh

MO_ini="$1" #first 1s core MO
MO_fin="$2" #last 1s core MO
out_file="$3" #residue A core MO population obtained from step2.sh
atmcore="$4" #atom type from the core space (C, N, S)
wavef="$5" #core orbital type (s,p)

#Creating the MO matrix using resA_mo.out (out_file)


#comment
atm_line="$(grep -n "num-1 sym lvl" $out_file | cut -d':' -f1)" #getting position lines having info

#getting the atom number involved in each field having MO information
#same atom number can be involved in several MO from different fields generating
# atom number repetition

#for ii in $atm_line #(necessary inefficient step)
#do
#      ii=$((ii+1))
#      atm_n="${atm_n} $(awk -v x=$ii 'NR==x {printf "%d\n", $1}' $out_file)"
#done
#comment the for above

awk '{if ($1 != "num-1") print $1}' $out_file > tmp1
uniq_atm="$(cat tmp1 | sort -u | uniq)" 
######check
#getting the unique elements (atom numbers)

#uniq_atm="$(echo "${atm_n}" | awk '{for (c=1;c<=NF;c++) { if ($c != $(c+1))  s=s" "$c } print s }')"

key_mo="$(seq -s "  " $MO_ini 1 $MO_fin | cat)" #writing the in-1-line MO range for residue A
key_mo="num-1 sym lvl  "${key_mo} 

echo "${key_mo}" > resA_MOcore.tmp #writing the head for the .csv data
rm -rf resA_popMO.tmp

dMO=$(($MO_fin-$MO_ini))

#creating the population matrix: atom number, MOs
#dimension of the matrix(i,j): (total C atoms from res A, $dMO)
for ii in $uniq_atm
do
      
      #getting line number when atom target is placed in resA_mo.out
      grep -n "${ii} C" $out_file > res_tmp.tmp
      sed -i 's/:/ /g' res_tmp.tmp # removing : to get 
      same_atm="$(awk -v x=${ii} '{if($2==x) print $1}' res_tmp.tmp)"

      #awk '{print $0}' res_tmp.tmp | cut -d':' -f1
      #same_atm="$(grep -n "${ii} C" $out_file | cut -d':' -f1)"

      #creating the zeroes row
      pop_val="$(awk -v y=${dMO} 'BEGIN { while (c++<=y) s=s " 0.0 "; print s}')"
      pop_val="$(echo "${ii} ${atmcore}  ${wavef}  ${pop_val}")"
     
      #creating the matrix in order, atom by atom (sorted) and including repetitions
      for iii in $same_atm
      do
	    #strategy: using the dictionary-like in bash to catch MO and its contributions per atom
            unset mo_atm
            declare -A mo_atm

	    # sometimes tmp_head is redundant but necessary in cases like core MO,
	    # tmp_head is just the header format (containing 6 MO)
	    # printing all the lines before the linematch, inverting the outout (tac),
            # printing just the second pattern and choosinig just the first one
	    tmp_head="$(awk -v x=$iii 'NR==x{exit} 1' $out_file | tac | sed -n '/num-1 sym lvl/p' | head -1)"
      
            #jj=$(($iii-1))
            
            for kk in {1..6} #core MO are presented in groups of 6
            do
            	  col=$(($kk+3))
            	  #key="$(awk -v x=$jj -v y=$col 'NR==x {printf "%s", $y}' $out_file)"
		  key="$(echo $tmp_head | awk -v y=$col '{printf "%s", $y}')"

		  #in some cases MO groups have addiitonal MO that are not from core
		  # the following conditional avoids mistakes copying unnecessary MOs
		  if (( "$(echo "${key} ${MO_ini} ${MO_fin}" | awk '{print $1<=$3 && $1>=$2}')" == 1 )); then
		  #if (( $key <= $MO_fin && $key >= $MO_ini )); then
			  mo_atm[$key]="$(awk -v x=$iii -v y=$col 'NR==x {printf "%s", $y}' $out_file)"
			  #storing the MO that its pupulation contributes greater than 5%
			  #if (( ${mo_atm[$key]} >= 5.0 )); then #float number not accepted 
			  if (( "$(echo "${mo_atm[$key]} 5.0" | awk '{print $1>=$2}')" == 1 )); then
				  echo "${key}" >> resA_popMO.tmp
			  fi

			  #echo "$key - ${mo_atm[$key]}" #uncomment this to check behavior
	          #else   #uncomment the else statement to check behavior
			  #echo "out of the MO interval"
		  fi
            done
            
            #reading the dictionary
            for kk in ${!mo_atm[@]}
            do
      	          #assigning in aux variable due to the syntaxis limits in awk
      	          aux=${mo_atm[$kk]}
      	          
      	          pos="$(echo "${key_mo}" | awk -v b="$kk" '{for (c=1;c<=NF;c++) { if ($c == b) { print c } }}')"
      	          #updating population for the target atom
		  pop_val="$(echo "$pop_val" | awk -v x=$pos -v y=$aux '{ $x = y; print $0}')"
      
		  #echo $pop_val #uncomment this to check behavior
            done
      
      done
      echo $pop_val >> resA_MOcore.tmp

done

rm -rf res_tmp.tmp
mv tmp1 resA_atomslist.out
mv resA_MOcore.tmp resA_MOcore.out

sed -r 's/\s+/,/g' resA_MOcore.out > resA_MOcore.csv

#four files as output from this script (resA_popMO.tmp, resA_atomslist.out, resA_MOcore.out, resA_MOcore.csv)
