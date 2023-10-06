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
	# this command operates under three conditions: 
	if (( $opt_soc==0 )); then
		sed -ne "/$(echo STATE $ex_ini | awk '{printf("%s%4d ",$1,$2)}')/,/$(echo STATE $ex_fin | awk '{printf("%s%4d",$1,$2+1)}')/p" $out2_file1 > exc_states.tmp
	elif (( $opt_soc==1 )); then
		out2_file12="exc_states2_transitions.out"
		sed -ne "/$(echo STATE $ex_ini | awk '{printf("%s%4d ",$1,$2)}')/,/$(echo STATE $ex_fin | awk '{printf("%s%4d",$1,$2+1)}')/p" $out2_file1 > exc_states.tmp
		sed -ne "/$(echo STATE $ex_ini | awk '{printf("%s%4d ",$1,$2)}')/,/$(echo STATE $ex_fin | awk '{printf("%s%4d",$1,$2+1)}')/p" $out2_file12 > exc_states2.tmp
	else # restricted (for now) for additive option
		# SOC option is done including default and higher multiplicity options
		out2_file12="exc_states2_transitions.out"
		out2_file13="exc_states3_transitions.out"
		sed -ne "/$(echo STATE $ex_ini | awk '{printf("%s%4d ",$1,$2)}')/,/$(echo STATE $ex_fin | awk '{printf("%s%4d",$1,$2+1)}')/p" $out2_file1 > exc_states.tmp
		sed -ne "/$(echo STATE $ex_ini | awk '{printf("%s%4d ",$1,$2)}')/,/$(echo STATE $ex_fin | awk '{printf("%s%4d",$1,$2+1)}')/p" $out2_file12 > exc_states2.tmp
		sed -ne "/$(echo State $ex_ini | awk '{printf("%s %d: ",$1,$2)}')/,/$(echo State $ex_fin | awk '{printf("%s %d:",$1,$2+1)}')/p" $out2_file13 > exc_states3.tmp
	fi

fi

# getting the excited state number involved in each field having transitions information
# same excited state number can be involved in several transitions from different fields,
# so repeated information is collected
atm_lst="$(awk '$2=="C"{ printf "%d\n", $1 }' $out1_file3)" #getting target atoms list
#trans_line="$(grep -n " C s" $out_file3 | cut -d':' -f1)" #getting position lines having info

# creating a list of unique MOs numerically ordered
uniq_MO="$(cat $out2_file3 | sort -nu | uniq)"

# the previous list (uniq_MO) now is listed in file to be read
# line by line in the following loop
echo $uniq_MO | awk -F" " '{for (i=1; i<=NF; i++) print $i}' > mo2_line.tmp
# Each line in mo2_line.tmp corresponds to the core MOs

# zero is the default option S'=S
# Default option is done regardless of the previous selection
# higher multiplicity is an additive option to the default one
# SOC is an additive option to the default one

## default option: S'=S
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

#two files as output from this script (virt_MO.tmp, trans_st.out)
