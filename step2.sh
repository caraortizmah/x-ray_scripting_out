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

#selecting just the core MOs that represents the residue of interest (res A) atoms

#deleting tmp if necessary
rm -rf resA_mo_3.tmp resA_mo_2.tmp resA_mo_2_1.tmp resA_mo.tmp

for ii in $( seq $MO_ini 1 $MO_fin )
do

      for jj in $( seq $A_ini 1 $A_fin ) #screening in the atom range
      do
	    #copying section having MO target up to find a blank line
            sed -n "/  $ii  /,/^$/p" $out_file > resA_mo.tmp 
	    head="$(sed -n '1p' resA_mo.tmp)" #MO number list (usually 6 MOs)
	    #copying section having atom number target
	    grep -n "${jj} C  s" resA_mo.tmp | cut -d':' -f2 | awk -v x=${jj} '{if($1==x) print $0}' | awk '{if(NF==9) print $0}' > resA_mo_2_1.tmp
	    # last command: awk -v x=${jj} '{if($1==x) print $0}', is to avoid wrong string matches e.g. '8  C' and '78  C'

	    awk -v x="${head}" '{printf "num-1 sym lvl %s\n%s\n\n", x, $0}' resA_mo_2_1.tmp >> resA_mo_2.tmp

      done

      #copying number lines where target atom is found
      #atm_line="$(grep -n "${jj} C  s" resA_mo_2.tmp | cut -d':' -f1)"

      #for ii in $atm_line
      #do
      #      #extracting lines pair having MO number (1st line) and
      #      #population distribution (2nd line)  
      #      kk=$(($ii-1))
      #      sed -n "${kk},${ii}p" resA_mo_2.tmp >> resA_mo_3.tmp
      #done
done
      #awk '!seen[$0]++' resA_mo_3.tmp > resA_mo_4.tmp 2> /dev/null #removing duplicates and throwing away stderr
awk '!seen[$0]++' resA_mo_2.tmp > resA_mo_3.tmp 2> /dev/null #removing duplicates and throwing away stderr
      #rm -rf resA_mo_3.tmp
      #cat resA_mo_4.tmp >> resA_mo_5.tmp #adding to the output
      #cat resA_mo_3.tmp >> resA_mo_4.tmp #adding to the output

#done

#comment the following line to check the writing-on-disk process
rm -rf resA_mo_2.tmp resA_mo_2_1.tmp resA_mo.tmp
#removing empty lines
sed -i '/^$/d' resA_mo_3.tmp
mv resA_mo_3.tmp resA_mo.out

#one file as output from this script
