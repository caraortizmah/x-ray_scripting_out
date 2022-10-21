#!/bin/bash

# script to create .csv format to be used in python

suf=".out.absq.dat"
for vars in `ls *.out.absq.dat`
do
	job=${vars/%$suf}
	awk '{ printf "%s,%s,%s,%s,%s\n", $1, $2, $3, $4, $5  }' $vars > $job.csv
done
