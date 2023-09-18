#!/bin/bash


workdir="$1"

for ii in `ls ${workdir}/*.out`
do
	job="$(echo "$ii" | awk -F '[/]' '{print $(NF)}')"
	cp $ii .
	./manager.sh 0 22 23 46 7 24 $job
done
