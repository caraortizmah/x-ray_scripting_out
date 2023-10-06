#!/bin/bash

# workdir is the absolute path where you have placed all the ORCA output files
# this path should be a folder having exclusively the .out files

workdir="$1"

for ii in `ls ${workdir}/*.out`
do
	job="$(echo "$ii" | awk -F '[/]' '{print $(NF)}')"
	cp $ii .
	./manager.sh 0 22 23 46 7 24 0 $job 1-17
done
