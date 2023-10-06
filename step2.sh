#!/bin/bash

# A_ini and A_fin are the atom range that represents the
#  residue of interest (res A) as occupied core MO
# MO_ini and MO_fin are the range of core MO corresponding
#  to C 1s, it is necessary to adapt it for N and O
# out_file is the core MO population in the specific format
#  that was created previously in the step1.sh

A_ini="$1" #first atom number for residue A
A_fin="$2" #last  atom number for residue A
MO_ini="$3" #first 1s core MO
MO_fin="$4" #last 1s core MO
out_file="$5" #core MO population obtained from step1.sh

# selecting just the core MOs that represents the target atoms
# here called as the residue A (res A) because of the interest of studying
# amino acids on proteins.

# deleting tmp if necessary
rm -rf resA_mo_3.tmp resA_mo_2.tmp resA_mo_2_1.tmp resA_mo2.tmp resA_mo3.tmp mo_line.tmp

# copying from the linenumber, where the MO target is, to the first blank
# line is found
# in this temporary file, MOs are copied with a subsequent list of atoms 
# that correspond to their population contributions to that MO
for ii in $( seq $MO_ini 1 $MO_fin )
do
      sed -n "/  $ii  /,/^$/p" $out_file >> resA_mo2.tmp
done

# there are until 6 MOs placed in the same numberline in step1.sh output
# it means that sections having a MO and its atom list contribution can be 
# repeated up to 6 times. There may be redundancies.
# Removing duplicates, and preserving unique  
# and throwing away stderr
awk '!seen[$0]++' resA_mo2.tmp > resA_mo3.tmp 2> /dev/null 

# creating mo_line.tmp as temporary file with a list of numberline position
# of the MO list
for ii in $( seq $MO_ini 1 $MO_fin )
do
      # getting position lines having redundancies
      echo "$(grep -n "  $ii  " resA_mo3.tmp | cut -d':' -f1)" >> mo_line.tmp 
done

# creating a list of uniq linenumber positions including the last linenumber
# of the file
echo "$(wc -l resA_mo3.tmp | cut -d" " -f1)" >> mo_line.tmp
uniq_mo_l="$(cat mo_line.tmp | sort -nu | uniq)"

# the previous list (uniq_mol_l) now is organized by tuples
# where the first position of the tuple is the initial linenumber of the 
# MO-atom-list section and the second position of the tuple is the last
# linenumber of that MO-atom-list section
echo $uniq_mo_l | awk -F" " '{for (i=1; i<NF; i++) print $i,$(i+1)}' > mo_line.tmp

# Each line in mo_line.tmp corresponds to a range linenumber of MO-atom-list
# section.
# All the MO-atom-list sections were copied (no redundancies) previously in
# the temporary file resA_mo3.tmp

# for each MO-atom-list section, do:
while read -r line
do
      row1="$(echo $line | awk '{print $1}')" #initial position
      row2="$(echo $line | awk '{print $2}')" #final position

      for jj in $( seq $A_ini 1 $A_fin ) #screening in the atom range
      do
	    # getting MO number list (usually 6 MOs) in that specified position line
            head="$(sed -n ''"$row1"'p' resA_mo3.tmp)"
	    # looking for a specific atom ($jj), with some specific pattern (grep command), in
	    # a specific range linenumber (sed command) in the file resA_mo3.tmp. 
	    # After cutting it and taking the second field (cut command). The numerical match
	    # is done (1st awk command) and print it just if contains 9 fields (2nd awk command)
	    # as in the original out file
	    sed -n ''"$row1"','"$row2"'p' resA_mo3.tmp | grep -n "${jj} C  s" | cut -d':' -f2 | awk -v x=${jj} '{if($1==x) print $0}' | awk '{if(NF==9) print $0}' > resA_mo_2_1.tmp
	    # print $head as first line and after the line pattern found in the temporary
	    # file resA_mo_2_1.tmp
	    awk -v x="${head}" '{printf "num-1 sym lvl %s\n%s\n\n", x, $0}' resA_mo_2_1.tmp >> resA_mo_2.tmp
      done

done < mo_line.tmp

# removing duplicates and throwing away stderr
awk '!seen[$0]++' resA_mo_2.tmp > resA_mo_3.tmp 2> /dev/null

#removing empty lines
sed -i '/^$/d' resA_mo_3.tmp
mv resA_mo_3.tmp resA_mo.out

#comment the following line to check the writing-on-disk process
rm -rf resA_mo_2.tmp resA_mo_2_1.tmp mo_line.tmp resA_mo2.tmp resA_mo3.tmp

#one file as output from this script (resA_mo.out)
