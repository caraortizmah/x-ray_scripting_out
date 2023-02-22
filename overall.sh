#!/bin/bash

#list="2.5 2.6 2.8 2.9 3.0 4.0 4.5 5.0 6.0 6.5 7.0 8.0 8.5 9.5 10.0 10.5"

for ii in `ls ../outs/*.out`
do
	job="$(echo "$ii" | cut -d'/' -f3)"
	cp $ii .
	./manager.sh 0 22 23 46 7 24 $job
done
