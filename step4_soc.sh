#!/bin/bash

# This script is called when SOC option is activated, the list of 
# excited states with their core-virtual coupling MOs is different
# when the output includes SOC. This script redo the list for the
# following steps

out4_file3="$1" # excited states output from step4.sh (trans_st3.out)
out1_file1="$2" # excited states output from step1.sh (exc_states_transitions.out)
out1_file2="$3" # excited states output from step1.sh (exc_states2_transitions.out)
out1_file3="$4" # excited states list from step1.sh (exc_energies_list.out)

# listing the line after finding the word "State " in trans_st3.out
# The file trans_st3.out has, as format, for each state a subsequent line
# having weight, root number and multiplicity type.
grep -n "State " $out4_file3 | cut -d':' -f1 | awk '{print $0+1}' >  tmp.tmp.tmp

while read -r line # SOC
do
      # total weight for the same root in the same State 
      target_weight="$(sed -n "${line}p" "${out4_file3}" | awk '{print $1}')"
      
      # root number
      target_root="$(sed -n "${line}p" "${out4_file3}" | awk '{print $2}')"

      # multiplicity type
      target_mult="$(sed -n "${line}p" "${out4_file3}" | awk '{print $3}')"

      # getting energy from the number root line in the list of exc_energies_list.out
      energy="$(awk -v x="$target_root" '{if($1==x) printf("%.1f\n",$4)}' ${out1_file3})"

      # choosing from which file to look for an energy match according to
      # the multiplicity type
      if (( $target_mult==0 )); then
	      echo "$(sed -n "/ ${energy}cm/,/^$/p" $out1_file1)" \
		      > exc_states_soc.tmp
      elif (( $target_mult==1 )); then
	      #sed -ne "/ ${energy}cm**-1 /,/^$/p" ${out1_file2} \
	      sed -n "/ ${energy}cm/,/^$/p" $out1_file2 \
		      > exc_states_soc.tmp 
      else
	      echo "STATE   XXX - error in the multiplicity" \
		      > exc_states_soc.tmp
      fi

      # adding the target weight to each pair MO coupling 
      awk -v x=$target_weight '{if ($1!="STATE" && NF!=0){print $0, x}else{print $0}}'\
	      exc_states_soc.tmp >> exc_states_soc_transitions.out

done < tmp.tmp.tmp

rm tmp.tmp.tmp exc_states_soc.tmp

#one file as output from this script (exc_states_soc_transitions.out)
