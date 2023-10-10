#!/bin/bash

out_file5="$1" # raw file containing virtual MO population involved in resB (resB_mo.out)

option="1"
#  you can select between two options:
# 1. summing all MO from the same number atom
# 2. summing MO according to their hibridization level (s,p,d)
#awk '{b[$2]+=$1} END { for (i in b) { print b[i],i } } ' file.txt

# splitting the scanning by groups, collected by "num-1 sym lvl"
head_line="$(grep -n "num-1 sym lvl " $out_file5 | cut -d':' -f1)" #getting position lines

# the previous list (head_line) is now organized by tuples
# where the first position of the tuple is the initial linenumber of the 
# MO-atom-list section and the second position of the tuple is the last
# linenumber of that MO-atom-list section
echo $head_line | awk -F" " '{for (i=1; i<NF; i++) print $i,$(i+1)}' > head2_line.tmp
# Each line in head2_line.tmp corresponds to a range linenumber of MO-atom-list
# section.
## All the MO-atom-list sections were copied (no redundancies) previously in
## the temporary file resA_mo3.tmp

## for each MO-atom-list section, do:
##while read -r line

rm -rf resB_collapsed"${option}"_*.tmp resB_collapsedMO.tmp

for ii in $head_line
do
      jj=$(($ii+1))
      sed -n "${jj},/num-1 sym lvl /{x;p;}" $out_file5 > resB_collapsed"${option}"_1.tmp
      # copying from specific line up to find the pattern without copying it
      
      # removing first empty line due to the previous format
      awk 'NR!="1"{print $0}' resB_collapsed"${option}"_1.tmp > resB_1.tmp
      mv resB_1.tmp resB_collapsed"${option}"_1.tmp

      # awk command to collapse rows having the same atom number by summing their pop MO
      # contributions, conserving the same order in rows and columns at the end
      awk '{a[$1]+=$4; b[$1]+=$5; c[$1]+=$6; d[$1]+=$7; e[$1]+=$8; f[$1]+=$9} \
	      END { for (i in a) { print i,a[i],b[i],c[i],d[i],e[i],f[i] } } ' \
	      resB_collapsed"${option}"_1.tmp > resB_collapsed"${option}"_21.tmp

      # obtaining the non-repeated list of atoms that belongs to each atom number 
      awk '!a[$1]++ {print $2}' resB_collapsed"${option}"_1.tmp > resB_collapsed"${option}"_22.tmp
     
      # zipping resB_collapsed${option}_21.tmp and (...)_22.tmp to preserve the original format
      awk 'FNR==NR { a[FNR""] = $0; next } { printf "%s\t%s  - %10s%10s%10s%10s%10s%10s\n", \
	$1, a[FNR""], $2, $3, $4, $5, $6, $7 }' resB_collapsed"${option}"_22.tmp \
	resB_collapsed"${option}"_21.tmp > resB_collapsed"${option}"_3.tmp

      sed -n "${ii}p" $out_file5 >> resB_collapsedMO.tmp #MO number list (usually 6 MOs)

      #echo $head >> resB_collapsedMO.out
      cat resB_collapsed"${option}"_3.tmp >> resB_collapsedMO.tmp

done

rm -rf resB_collapsed"${option}"_*.tmp
mv resB_collapsedMO.tmp resB_collapsedMO.out

#one file as output from this script (resB_collapsedMO.out)
