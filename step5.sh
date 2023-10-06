#!/bin/bash

# B_ini and B_fin are the atom range that represents the
#  residue of interest (res B) as virtual MO
# out_file is the core MO population in the specific format
#  that was created previously in the step1.sh

B_ini="$1" #first atom number for residue B
B_fin="$2" #last  atom number for residue B
#MO_ini="$3" #first 1s core MO
#MO_fin="$4" #last 1s core MO
out1_file="$3" # core MO population obtained from step1.sh
out1_file4="$4" # virt_MO.tmp core MO population obtained from step1.sh

# selecting just the virtual MOs that represents the target atoms
# here called as the residue B (res B) because of the interest of studying
# amino acids on proteins.

#deleting tmp if necessary
rm -rf resB_mo_3.tmp resB_mo_2.tmp resB_mo_2_1.tmp resB_mo.tmp

# instancing unique virtual MOs in one variable
virt_mo="$(cat $out1_file4 | sort -nu | uniq)" 

for ii in $virt_mo
do
      sed -n "/  $ii  /,/^$/p" $out1_file >> resB_mo2.tmp
done
awk '!seen[$0]++' resB_mo2.tmp > resB_mo3.tmp 2> /dev/null 

for ii in $virt_mo # screening in the virtual MOs range
do
	# getting position lines having redundancies
	echo "$(grep -n "  $ii  " resB_mo3.tmp | cut -d':' -f1)" >> vmo_line.tmp
done
echo "$(wc -l resB_mo3.tmp | cut -d" " -f1)" >> vmo_line.tmp
uniq_vmo_l="$(cat vmo_line.tmp | sort -nu | uniq)"
echo $uniq_vmo_l | awk -F" " '{for (i=1; i<NF; i++) print $i,$(i+1)}' > vmo_line.tmp
# for each virtual MO-atom-list section, do:
while read -r line # virtual MOs
do
      row1="$(echo $line | awk '{print $1}')" #initial position
      row2="$(echo $line | awk '{print $2}')" #final position
      #virt_mo="$(awk '{printf "%s ", $0}' $out1_file4)"
      
      for jj in $( seq $B_ini 1 $B_fin ) #screening in the atom range
      do
	    # getting MO number list (usually 6 MOs) in that specified position line
            head="$(sed -n ''"$row1"'p' resB_mo3.tmp)"
	    # looking for a specific atom ($jj), with some specific pattern (grep command), in
	    # a specific range linenumber (sed command) in the file resB_mo3.tmp. 
	    # After cutting it and taking the second field (cut command). The numerical match
	    # is done (1st awk command) and print it just if contains 9 fields (2nd awk command)
	    # as in the original out file
	    sed -n ''"$row1"','"$row2"'p' resB_mo3.tmp | grep -n "${jj} " | cut -d':' -f2 | awk -v x=${jj} '{if($1==x) print $0}' | awk '{if(NF==9) print $0}' > resB_mo_2_1.tmp
	    awk -v x="${head}" '{printf "num-1 sym lvl %s\n%s\n\n", x, $0}' resB_mo_2_1.tmp >> resB_mo_2.tmp

	    # separating, even for the same atom number, by MO level (s,p,d)
	    #if (( $(wc -l resB_mo_2_1.tmp | cut -d' ' -f1) > 1)); then
		    #echo "here" $head
	    #else
	    #        awk -v x="${head}" '{printf "num-1 sym lvl %s\n\n", x, $0}' resB_mo_2_1.tmp >> resB_mo_2.tmp
	            #echo " " | awk '{printf "\n"}' >> resB_mo_2_1.tmp
	            #mv resB_mo_2_1.tmp resB_mo_2.tmp
	    #fi
	    #$"(grep -n "${jj} " resB_mo.tmp)" resB_mo_2.tmp
      done

done < vmo_line.tmp

awk '!seen[$0]++' resB_mo_2.tmp > resB_mo_3.tmp 2> /dev/null

#removing empty lines
sed -i '/^$/d' resB_mo_3.tmp
echo " " >> resB_mo_3.tmp
mv resB_mo_3.tmp resB_mo.out

#comment the following line to check the writing-on-disk process
rm -rf resB_mo_2.tmp resB_mo_2_1.tmp resB_mo.tmp

#one file as output from this script (resB_mo.out)
