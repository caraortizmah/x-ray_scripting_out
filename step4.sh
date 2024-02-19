#!/bin/bash

out2_file1="$1" #excited states output from step1.sh (exc_states_transitions.out)
out1_file3="$2" #res-A core-MO population matrix (resA_MOcore.out)
out2_file3="$3" #core-MO population of res-A C-atoms, greater than 5% (resA_popMO.tmp)
opt_soc="$4" #multiplicity and SOC option, default is 0 (S'=S), 1 (S'=S+1, including SOC) 
arg_exc="$5" #excited states range
#atmcore="$6" #atom type from the core space (C, N, S)

# Two different procedures to read excited states
if (( $opt_soc==0 ));then
        
	# no SOC option (only low multiplicity)
	# cleaning transition states file by a defined range of excited states
        if [[ "$arg_exc" == "none" ]]; then
        	
        	# copying all the excited states (default: none)
                sed -ne '/STATE   1 /,$ p' $out2_file1 > exc_states.tmp
        else
        	# copying a range of excited states specified in $arg_exc
        	ex_ini="$(echo $arg_exc | cut -d'-' -f1)" # initial excited state
        	ex_fin="$(echo $arg_exc | cut -d'-' -f2)" # final excited state
        
        	# The command below 'sed -ne "(...)" $out2_file1 > (...)' does: 
        	# copy excited states list range (sed command) using as variables
        	# the word 'STATE' combined with (specifically numerical format)
        	# the excited state number (initial and final)
        	# this command operates under three conditions:
                sed -ne "/$(echo STATE $ex_ini | awk '{printf("%s%4d ",$1,$2)}')/,/$(echo STATE $ex_fin | awk '{printf("%s%4d",$1,$2+1)}')/p" $out2_file1 > exc_states.tmp
	fi

else

        # SOC option (both: low and high multiplicity)
	out2_file13="exc_states3_transitions.out"
	
	if [[ "$arg_exc" == "none" ]]; then

        	# copying all the excited states (default: none)
                sed -ne '/State 1: /,$ p' $out2_file13 > exc_states3.tmp
	else
		# copying (again) a range of excited states specified in $arg_exc
        	ex_ini="$(echo $arg_exc | cut -d'-' -f1)" # initial excited state
        	ex_fin="$(echo $arg_exc | cut -d'-' -f2)" # final excited state
	
	# In the if statement condition the same command is used over different files
	#	out2_file12="exc_states2_transitions.out"
	#	sed -ne "/$(echo STATE $ex_ini | awk '{printf("%s%4d ",$1,$2)}')/,/$(echo STATE $ex_fin | awk '{printf("%s%4d",$1,$2+1)}')/p" $out2_file12 > exc_states2.tmp
		
		sed -ne "/$(echo State $ex_ini | awk '{printf("%s %d: ",$1,$2)}')/,/$(echo State $ex_fin | awk '{printf("%s %d:",$1,$2+1)}')/p" $out2_file13 > exc_states3.tmp
	fi

fi

# getting the excited state number involved in each field having transitions information
# same excited state number can be involved in several transitions from different fields,
# so repeated information is collected
# ##check## this: atm_lst is not called
# atm_lst="$(awk -v x="${atmcore}" '$2==x{ printf "%d\n", $1 }' $out1_file3)" #getting target atoms list
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

#####     Default option: S'=S     #####

if (( $opt_soc==0 )); then
        
       # This conditional is just in case the pattern is for the last excited state
       num_sts="$(grep -n "STATE " exc_states.tmp | cut -d':' -f1 | wc -l)"
       if [[ "$num_sts" == "1" ]]; then
	       echo "STATE " >> exc_states.tmp
       fi

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

#####        Option: S'=S+1        #####
#####      ergo SOC evaluation     #####


#if (( $opt_soc==1 )); then
#	# Commands explanation in the default case
#	#  same commands and order such as previous case 
#	#  but for the higher multiplicity
#        state2_line="$(grep -n "STATE " exc_states2.tmp | cut -d':' -f1)" 
#        
#        echo $state2_line | awk -F" " '{for (i=1; i<NF; i++) print $i,$(i+1)-1}' > state2_line.tmp  
#        
#        rm -rf trans_st2.out virt_MO2.tmp trans_st2.tmp
#        
#	while read -r line # S'=S+1
#        do
#              row="$(echo $line | awk '{print $1}')" # position line of excited state 
#              row2="$(echo $line | awk '{print $2}')" # final position
#              
#              head_state="$(sed -n "${row}p" exc_states2.tmp)"
#              row1=$(($row+1)) # initial position
#        
#              echo "$(sed -n ''"$row1"','"$row2"'p' exc_states2.tmp)" > state_tmp2.tmp
#              
#	      awk -v x="$head_state" -F'[-]' 'NR==FNR{a[$0]=1; next} {for(i in a) if($1+0 == i+0){printf "%s\n%s\n",x,$0}}' mo2_line.tmp state_tmp2.tmp >> trans_st2.tmp
#        
#        done < state2_line.tmp
#        
#        sed -n "/->/p" trans_st2.tmp | cut -d'>' -f2 | cut -d' ' -f1 | sort -nu | uniq > virt_MO2.tmp
#        
#        mv trans_st2.tmp trans_st2.out


#####      SOC evaluation     #####

if (( $opt_soc==1 )); then

        # To overwrite an existing report
	rm -rf err_report_step4_min.out
	# This conditional is just in case the pattern is for the last excited state
	num_sts="$(grep -n "State " exc_states3.tmp | cut -d':' -f1 | wc -l)"
	if [[ "$num_sts" == "1" ]]; then 
		echo "State " >> exc_states3.tmp
	fi
	# Commands explanation in the first case
	#  same commands and order such as previous case
	#  but for the SOC case
        state3_line="$(grep -n "State " exc_states3.tmp | cut -d':' -f1)" 
        
        echo $state3_line | awk -F" " '{for (i=1; i<NF; i++) print $i,$(i+1)-1}' > state3_line.tmp  
	
	rm -rf virt_MO3.tmp trans_st3.tmp
 
	# The following three lines are for clarification of the trans_st3.out file
	#  because it has different format 
	echo "Eigenvectors of SOC calculation" > trans_st3.out
	echo "Number of state: Exc. Energy cm**-1   Exc. Energy cm**-1" >> trans_st3.out
	echo "Weight  Root  Spin " >> trans_st3.out
	
	while read -r line # SOC
        do
              row="$(echo $line | awk '{print $1}')" # position line of excited state 
              row2="$(echo $line | awk '{print $2}')" # final position
              
              head_state="$(sed -n "${row}p" exc_states3.tmp)"
              row1=$(($row+1)) # initial position
        
	      # Threshold in the weighted list 0.2%
	      echo "$(sed -n ''"$row1"','"$row2"'p' exc_states3.tmp)" | awk '{if($1>0.02) printf "%s\n",$0}' > tobe_collapsed.tmp
	      
	      # Collapsing rows in one by summing the first column (weight) when they have 
	      #  the same root number (column 5th)
	      #  root number will always have an unique spin number e.g.:
              #    root   spin  Ms         |  root   spin   Ms
	      #     9      1    -1   [OK]  |   9      0      0   [X]
	      #     9      1     1   [OK]  |   9      1      1   [X]
	      #    21      0     0   [OK]  |  21      0      0   [OK]
	      # Assigning variables to target columns ($1, $5, $6), if $5 is equal to 
	      #  the next $5 then $1 and the next are summed.
	      # When there is not a match between $5 and next $5, then the values
	      #  from the current FNR are printed.
              awk '{a=$1; b=$5; m=$6; if(FNR>1){if(b==d){auxa=auxa+a}else{ \
		      print auxa,d,n; auxa=a; auxb=b; auxm=m}}else{auxa=a; auxb=b; auxm=m} c=$1; d=$5; n=$6} \
		      END{print auxa,auxb,auxm}' tobe_collapsed.tmp > collapsed.tmp

	      # In some cases the target "State" just contains one single root,
	      #  which should have a weight aproximately to 1.0 (>=0.98).
	      # In the opposite case, only one root in only one "State" lower or 
	      #  equal than 0.98 of weight implies that something is missing in 
	      #  that spin representation and should require manual analysis 
	      if (( $(cat collapsed.tmp | wc -l)>1 )); then
		      # Adding "State" head for each new line (either collapsed or not)
		      awk -v x="$head_state" '{printf "%s\n%s\n",x,$0}' \
			      collapsed.tmp >> trans_st3.tmp
	      else
		      # Adding "State" head for the only line rounding up 1.0 the
		      #  weight ($1) if that's greater or equal than 0.98.
		      # If not, the weight will be forced to take 1.0 as value
		      #  and that incident will be report. A '*' will be added to
		      #  make that notorious in the output 
		      awk -v x="$head_state" '{if($1>=0.98){\
			      printf "%s\n%.1f %s %s\n",x,$1,$2,$3}else{ \
		              printf "%s\n1.0 %s %s *\n",x,$2,$3}}' \
			      collapsed.tmp >> trans_st3.tmp
		      
		      awk -v x="$head_state" '{if($1<0.98)\
        printf "In the SOC state: \n%s the root %s has a weight lower than expected (>=0.98): %s\n(original info): %s\n",x,$1,$2,$0}' \
	                              collapsed.tmp >> err_report_step4_min.out

	      fi

        done < state3_line.tmp
        
        cat trans_st3.tmp >> trans_st3.out

fi

# opt_soc = 0: two files as output from this script (virt_MO.tmp, trans_st.out)
# opt_soc = 1: two files as output from this script (virt_MO.tmp, trans_st3.out)
