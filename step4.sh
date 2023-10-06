#!/bin/bash

out2_file1="$1" #excited states output from step1.sh (exc_states_transitions.out)
out1_file3="$2" #res-A core-MO population matrix (resA_MOcore.out)
out2_file3="$3" #core-MO population of res-A C-atoms, greater than 5% (resA_popMO.tmp)
opt_soc="$4" #multiplicity and SOC option, default is 0 (S'=S), 1 (S'=S+1) and 2 (SOC) 
arg_exc="$5" #excited states range

# cleaning transition states file by a defined range of excited states
if (($arg_exc=="none")); then
	
	# copying all the excited states (default: none)
        sed -ne '/STATE   1 /,$ p' $out2_file1 > exc_states.tmp
else
	# copying a range of excited states specified in $arg_exc
	ex_ini="$(echo $arg_exc | cut -d'-' -f1)" # initial excited state
	ex_fin="$(echo $arg_exc | cut -d'-' -f2)" # final excited state

	# The following command 'sed -ne "(...)" $out2_file1 > file' does: 
	# copy excited states list range (sed command) using as variables
	# the word 'STATE' combined with (specifically numerical format)
	# the excited state number (initial and final)
	if (( $opt_soc==0 )); then
		sed -ne "/$(echo STATE $ex_ini | awk '{printf("%s%4d ",$1,$2)}')/,/$(echo STATE $ex_fin | awk '{printf("%s%4d",$1,$2+1)}')/p" $out2_file1 > exc_states.tmp
	fi

fi

# getting the excited state number involved in each field having transitions information
# same excited state number can be involved in several transitions from different fields,
# so repeated information is collected
atm_lst="$(awk '$2=="C"{ printf "%d\n", $1 }' $out1_file3)" #getting target atoms list
#trans_line="$(grep -n " C s" $out_file3 | cut -d':' -f1)" #getting position lines having info

# creating a list of unique MOs numerically ordered
uniq_MO="$(cat $out2_file3 | sort -nu | uniq)"

echo $uniq_MO | awk -F" " '{for (i=1; i<=NF; i++) print $i}' > mo2_line.tmp
if (( $opt_soc==0 )); then

        # getting position lines having info
        #state_line="$(grep -n "STATE " $out2_file1 | cut -d':' -f1)" 
        # getting position lines having info
        state_line="$(grep -n "STATE " exc_states.tmp | cut -d':' -f1)" 
        
        # the previous list (state_line) now is organized by tuples
        # where the first position of the tuple is the initial linenumber of the 
        # excited-state-list section and the second position of the tuple is the 
        # last linenumber of that excited-state-list section
        echo $state_line | awk -F" " '{for (i=1; i<NF; i++) print $i,$(i+1)-1}' > state_line.tmp  
        
        rm -rf trans_st.out virt_MO.tmp trans_st.tmp
        
        # for each excited-state-position-line in list, do:
        while read -r line
        do
              row="$(echo $line | awk '{print $1}')" # position line of excited state 
              row2="$(echo $line | awk '{print $2}')" # final position
              
              # getting the information of that line ($row) to use as head
              head_state="$(sed -n "${row}p" exc_states.tmp)"
              row1=$(($row+1)) # initial position
        
              # creating a temporary file with a specific range linenumber
              echo "$(sed -n ''"$row1"','"$row2"'p' exc_states.tmp)" > state_tmp.tmp
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
              awk -v x="$head_state" -F'[-]' 'NR==FNR{a[$0]=1; next} {for(i in a) if($1+0 == i+0){printf "%s\n%s\n",x,$0}}' mo2_line.tmp state_tmp.tmp >> trans_st.tmp
        
        done < state_line.tmp
        
        # exctracting from trans_st.tmp file the virtual MOs, ordering them numerically
        # and listing it in a file
        sed -n "/->/p" trans_st.tmp | cut -d'>' -f2 | cut -d' ' -f1 | sort -nu | uniq > virt_MO.tmp
        
        mv trans_st.tmp trans_st.out
fi

rm -rf trans_st.out virt_MO.tmp trans_st.tmp trans_st_2.tmp trans_st_2_1.tmp virt_MO.tmp

#for ii in $state_line
#do
#
#      sed -n "${ii},/^$/p" exc_states.tmp > trans_st_2.tmp #copying from specific line up to the first blank line
#
#      for jj in $uniq_MO
#      do
#            sed -n "/  ${jj}->/p" trans_st_2.tmp > trans_st_2_1.tmp
#	    #if there is not a match looking for $jj (core MO) skip that excited state
#	    if (( $(wc -l trans_st_2_1.tmp | cut -d' ' -f1) > 0 )); then
#
#                    sed -n "${ii}p" exc_states.tmp >> trans_st.tmp #copying head of that state
#                    awk '{printf "%s\n", $0}' trans_st_2_1.tmp >> trans_st.tmp
#	    fi
#	    sed -n "/  ${jj}->/p" trans_st_2.tmp | cut -d'>' -f2 | cut -d':' -f1 | cut -d' ' -f1 >> virt_MO.tmp
#      done
#      #echo " " | awk '{printf "\n"}' >> trans_st.tmp
#
#done

cat virt_MO.tmp | sort -u -n | uniq > virt_MO_2.tmp #saving the unique elements
mv virt_MO_2.tmp virt_MO.tmp

rm -rf trans_st_2.tmp trans_st_2_1.tmp
mv trans_st.tmp trans_st.out

#two files as output from this script (virt_MO.tmp, trans_st.out)
