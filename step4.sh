#!/bin/bash

out2_file1="$1" #excited states output from step1.sh (exc_states_transitions.out)
out1_file3="$2" #res-A core-MO population matrix (resA_MOcore.out)
out2_file3="$3" #core-MO population of res-A C-atoms, greater than 5% (resA_popMO.tmp)

#Creating the MO matrix using resA_mo.out (out_file)

state_line="$(grep -n "STATE " $out2_file1 | cut -d':' -f1)" #getting position lines having info

#getting the excited state number involved in each field having transitions information
#same excited state number can be involved in several transitions from different fields,
# so repeated information is collected

atm_lst="$(awk '$2=="C"{ printf "%d\n", $1 }' $out1_file3)" #getting target atoms list
#trans_line="$(grep -n " C s" $out_file3 | cut -d':' -f1)" #getting position lines having info

#getting the unique elements (MO numbers)
uniq_MO="$(cat $out2_file3 | sort -u -n | uniq)"

rm -rf trans_st.out virt_MO.tmp trans_st.tmp trans_st_2.tmp trans_st_2_1.tmp virt_MO.tmp

for ii in $state_line
do
      sed -n "${ii},/^$/p" $out2_file1 > trans_st_2.tmp #copying from specific line up to the first blank line

      for jj in $uniq_MO
      do
            sed -n "/  ${jj}->/p" trans_st_2.tmp > trans_st_2_1.tmp
	    #if there is not a match looking for $jj (core MO) skip that excited state
	    if (( $(wc -l trans_st_2_1.tmp | cut -d' ' -f1) > 0 )); then
                    sed -n "${ii}p" $out2_file1 >> trans_st.tmp #copying head of that state
                    awk '{printf "%s\n", $0}' trans_st_2_1.tmp >> trans_st.tmp
	    fi
	    sed -n "/  ${jj}->/p" trans_st_2.tmp | cut -d'>' -f2 | cut -d':' -f1 | cut -d' ' -f1 >> virt_MO.tmp
      done
      #echo " " | awk '{printf "\n"}' >> trans_st.tmp

done

cat virt_MO.tmp | sort -u | uniq > virt_MO_2.tmp #saving the unique elements
mv virt_MO_2.tmp virt_MO.tmp

rm -rf trans_st_2.tmp trans_st_2_1.tmp
mv trans_st.tmp trans_st.out

#two files as output from this script (virt_MO.tmp, trans_st.out)
