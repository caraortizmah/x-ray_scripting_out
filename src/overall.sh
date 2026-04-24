#!/bin/bash

# workdir is the absolute path where you have placed all the ORCA output files
# this path should be a folder having exclusively the .out files

workdir="$1"

for ii in `ls ${workdir}/*.out`
do
	job="$(echo "$ii" | awk -F '[/]' '{print $(NF)}')"
	cp $ii .
	./manager.sh 0 46 0 46 7 24 0 $job 1-26 1
done
