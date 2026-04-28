#!/bin/bash

# MO_ini and MO_fin are the range of core MO corresponding
#  to C 1s, it is necessary to adapt it for N and O
# out_file is the core MO population in the specific format
#  for the residue A created previously in the step2.sh

out_file4="$1" # virt MO (virt_MO.tmp)
out_file5="$2" # residue B core MO population from step6.sh (resB_collapsedMO.out)

# Creating the MO matrix using resB_collapsedMO.out (out_file)

virtmo_line="$(awk '{print $0}' $out_file4)" # getting virtual MO list
MO_ini="$(echo "$virtmo_line" |  head -1)"
MO_fin="$(echo "$virtmo_line" |  tail -1)"

# That is why initially is received a range of virtual MO
dMO=$(($MO_fin-$MO_ini))

atm_line="$(grep -n "num-1 sym lvl" $out_file5 | cut -d':' -f1)" # getting position lines

awk '{if ($1 != "num-1") print $1}' $out_file5 > tmp2
uniq_atm="$(cat tmp2 | sort -nu | uniq)" # listing non-repeated atoms

# Getting the unique elements (atom numbers)

key_mo="$(seq -s "  " $MO_ini 1 $MO_fin | cat)" # writing the in-1-line MO range for residue A
key_mo="num-1 sym lvl  "${key_mo} 

echo "${key_mo}" > resB_MOcore.tmp # writing the head for the .csv data
rm -rf resB_popMO.tmp 


for ii in $uniq_atm
do
      
      # Getting line number when atom target is placed in $out_file5
      # Using a combination of grep and awk to ensure that the match were absolutely correct
      same_atm="$(grep -n "${ii}" $out_file5 | awk -v x=$ii -F'[\t :]' '{if($2==x){print$1}}')"
      # Creating a zeroes row
      pop_val="$(awk -v y=${dMO} 'BEGIN { while (c++<=y) s=s " 0.0 "; print s}')"
      pop_val="$(echo "${ii} atom lvlMO ${pop_val}")"


      # Creating the matrix in order, atom by atom (sorted) and including repetitions
      for iii in $same_atm
      do
	      
            unset mo_atm
            declare -A mo_atm
            # Creating the population matrix: atom number, MOs
            # Dimension of the matrix(i,j): (total C atoms from res A, $dMO)

	    # Sometimes tmp_head is redundant but necessary in cases like virtual MO,
	    #  tmp_head is just the header format (containing 6 MO)
	    #  printing all the lines before the linematch, inverting the outout (tac),
            #  printing just the second pattern and choosinig just the first one
	    tmp_head="$(awk -v x=$iii 'NR==x{exit} 1' $out_file5 | tac | sed -n '/num-1 sym lvl/p' | head -1)"
	    # Strategy: using the dictionary-like in bash to catch MO and its contributions per atom
      
            #jj=$(($iii-1))
            
            for kk in {1..6} #core MO are presented in groups of 6
            do
            	  col=$(($kk+3))
            	  #key="$(awk -v x=$iii -v y=$col 'NR==x {printf "%s", $y}' $out_file5)"
		  key="$(echo $tmp_head | awk -v y=$col '{printf "%s", $y}')"

		  # In some cases MO groups have additional MO that are not from the target
		  # The following if statement avoids mistakes taking the numerically correct MOs
		  if (( "$(echo "${key} ${MO_ini} ${MO_fin}" | awk '{print $1<=$3 && $1>=$2}')" == 1 )); then
		          # Filling up the dictionary
			  mo_atm[$key]="$(awk -v x=$iii -v y=$col 'NR==x {printf "%s", $y}' $out_file5)"

			  # Storing the MO that its population contributes greater than 5%
			  if (( "$(echo "${mo_atm[$key]} 5.0" | awk '{print $1>=$2}')" == 1 )); then
				  echo "${key}" >> resB_popMO.tmp
			  fi

			  #echo "$key - ${mo_atm[$key]}" #uncomment this to check behavior
	          #else   #uncomment the else statement to check behavior
			  #echo "out of the MO interval"
		  fi

            done
            
            # Reading the dictionary
            for kk in ${!mo_atm[@]}
            do
      	          # Assigning in aux variable due to the syntaxis limits in awk
      	          aux=${mo_atm[$kk]}
#      	          
      	          pos="$(echo "${key_mo}" | awk -v b="$kk" '{for (c=1;c<=NF;c++) { if ($c == b) { print c } }}')"
#      	          # Updating population for the target atom
		  pop_val="$(echo "$pop_val" | awk -v x=$pos -v y=$aux '{ c=$x; $x=y+c; print $0}')"
      
#		  #echo $pop_val #uncomment this to check behavior
            done

      done
      echo $pop_val >> resB_MOcore.tmp
done

mv tmp2 resB_atomslist.out
mv resB_MOcore.tmp resB_MOcore.out

sed -r 's/\s+/,/g' resB_MOcore.out > resB_MOcore.csv

mo_list=$(seq $MO_ini 1 $MO_fin) # getting the same MO list used to create resB_MOcore.tmp

# Getting the difference between the MO in resB_MOcore.tmp and
#  those ones involved in transitions states
#  the new MO list (the difference) will be removed from resB_MOcore.tmp
diffe="$(diff -ia --suppress-common-lines <(echo "$mo_list") <(echo "$virtmo_line") | awk '$1=="<"{print $2}')"

for jj in $diffe
do
	# Obtaining the column position to remove
        mo_pos="$(awk 'NR==1{print $0}' resB_MOcore.csv)"
	pos="$(echo $mo_pos | awk -F, -v x=${jj} '{for (i=1; i<=NF; i++) {if ($i==x) print i}}')"

	#echo "jj: " $jj", mo_pos: " $mo_pos", pos: " $pos 
	echo $(cut --complement -d',' -f${pos} resB_MOcore.csv > resB_MOcore_tmp.csv)
        cp resB_MOcore_tmp.csv resB_MOcore.csv
done

sed -r 's/,/ /g' resB_MOcore.csv > resB_MOcore.out

# Three files as outputs from this script (resB_atomslist.out, resB_MOcore.out, resB_MOcore.csv)
