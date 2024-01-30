#!/bin/bash

# This script is called when S'=S+1/SOC option is activated, the list of 
#  excited states with their core-virtual coupling MOs is different
#  when the output includes SOC. This script redoes the list for the
#  following steps

out4_file3="$1" # excited states output from step4.sh (trans_st3.out)
out1_file1="$2" # excited states output from step1.sh (exc_states_transitions.out)
out1_file2="$3" # excited states output from step1.sh (exc_states2_transitions.out)
out1_file3="$4" # excited states list from step1.sh (exc_energies_list.out)

# Listing the line after finding the word "State " in trans_st3.tmp
# The file trans_st3.out has, as format, for each state a subsequent line
#  having weight, root number and multiplicity type.
grep -n "State " $out4_file3 | cut -d':' -f1 | awk '{print $0+1}' >  tmp.tmp.tmp

while read -r line # SOC
do
      # Total weight for the same root in the same State 
      target_weight="$(sed -n "${line}p" "${out4_file3}" | awk '{print $1}')"
      
      # Root number
      target_root="$(sed -n "${line}p" "${out4_file3}" | awk '{print $2}')"

      # Multiplicity type
      target_mult="$(sed -n "${line}p" "${out4_file3}" | awk '{print $3}')"

      # Getting energy from the number root line in the list of exc_energies_list.out
      energy="$(awk -v x="$target_root" '{if($1==x) printf("%.1f\n",$4)}' ${out1_file3})"

      # Choosing from which file to look for an energy match according to
      # The multiplicity type
      if (( $target_mult==0 )); then
	      echo "$(sed -n "/ ${energy}cm/,/^$/p" $out1_file1)" \
		      > exc_states_soc0.tmp # exc_states_soc.tmp

	      # Adding the target weight to each pair MO coupling and
              # the target root that will used in step9_soc.sh
              awk -v x=$target_weight -v y=$target_root \
        	      'NF!=0{if ($1!="STATE"){print $0, x}else{print $0, y}}'\
        	      exc_states_soc0.tmp >> exc_states_soc0_transitions.out

      elif (( $target_mult==1 )); then
	      #sed -ne "/ ${energy}cm**-1 /,/^$/p" ${out1_file2} \
	      sed -n "/ ${energy}cm/,/^$/p" $out1_file2 \
		      > exc_states_soc1.tmp # exc_states_soc.tmp
        
	      # Adding the target weight to each pair MO coupling and
              # the target root that will used in step9_soc.sh
              awk -v x=$target_weight -v y=$target_root \
        	      'NF!=0{if ($1!="STATE"){print $0, x}else{print $0, y}}'\
        	      exc_states_soc1.tmp >> exc_states_soc1_transitions.out

      else
	      echo "STATE   XXX - error in the multiplicity" \
		      > exc_states_soc_err.tmp # exc_states_soc.tmp
      fi

done < tmp.tmp.tmp

#rm tmp.tmp.tmp exc_states_soc.tmp

# virt_MO.tmp is already printed for S'=S, now will be rewritten for SOC evaluation
rm -rf virt_MO.tmp trans_st.tmp trans1_st.tmp

# Using the same algorithm for option S'=S
# In the future, this section of code should be a new script
# to be called for option 0 and 1

for ii in 0 1 # repeating same process for multiplicity 0 and 1
do
      cp exc_states_soc${ii}_transitions.out exc_states_soc${ii}_tr.tmp
      echo "STATE " >> exc_states_soc${ii}_tr.tmp
      
      ### copied code from step4.sh ###
      
      # getting position lines having info
      state_line="$(grep -n "STATE " exc_states_soc${ii}_tr.tmp | cut -d':' -f1)" 
      
      # the previous list (state_line) now is organized by tuples
      # where the first position of the tuple is the initial linenumber of the 
      # excited-state-list section and the second position of the tuple is the 
      # last linenumber of that excited-state-list section
      echo $state_line | awk -F" " '{for (i=1; i<NF; i++) print $i,$(i+1)-1}' > state3_line.tmp  
            
      # for each excited-state-position-line in list, do:
      while read -r line
      do
            row="$(echo $line | awk '{print $1}')" # position line of excited state 
            row2="$(echo $line | awk '{print $2}')" # final position
            
            # getting the information of that line ($row) to use as head
            head_state="$(sed -n "${row}p" exc_states_soc${ii}_tr.tmp)"
            row1=$(($row+1)) # initial position
      
            # creating a temporary file with a specific range linenumber
            echo "$(sed -n ''"$row1"','"$row2"'p' exc_states_soc${ii}_tr.tmp)" > state_tmp.tmp
            # idea: to find a way of "read-in-line" this previous sed command in the
            # following awk command to be faster running
      
            # Looking elements from the unique column of file1 in the first column of
            # the file2.
            # file1 is the list of core MOs (mo2_line.tmp) and file2 is the excited-
            # state information with their MO coupling (state_tmp.tmp) using the
            # format '->' to separate MOs. Then, separator used here is '-' and the
            # conditional statement has the two elements from the both columns with a
            # trivial sum of zero in order to ensure the nummerical comparison and not
            # the string comparison, e.g. 19 == 9 can be true if both elements are strings 
            awk -v x="$head_state" -F'[-]' 'NR==FNR{a[$0]=1; next} {for(i in a) if($1+0 == i+0){printf "%s\n%s\n",x,$0}}' mo2_line.tmp state_tmp.tmp >> trans${ii}_st.tmp
      
      done < state3_line.tmp
      
      rm -rf exc_states_soc${ii}_tr.tmp

      # Exctracting from trans_st.tmp file the virtual MOs, ordering them numerically
      #  and listing it in a file
      sed -n "/->/p" trans${ii}_st.tmp | cut -d'>' -f2 | cut -d' ' -f1 >> virt_MO.tmp1

      # Rewriting trans_st.out now with the information at the end of the SOC evaluation
      mv trans${ii}_st.tmp trans${ii}_st.out

done

cat virt_MO.tmp1 | sort -nu | uniq > virt_MO.tmp

#mv trans0_st.out trans_st.out
#mv exc_states_soc0_transitions.out exc_states_soc_transitions.out

rm -rf virt_MO.tmp1

# Two files as outputs from this script (exc_states_soc_transitions.out, virt_MO.tmp)
