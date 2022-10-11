#!/bin/bash

# converting MO population matrices (MO density matrices) in .csv format

resa="$1"
#resb="$2"
resab="$2"
resab_ts="$3"

namea="$(echo "${resa}" | cut -d'.' -f1)"
#nameb="$(echo "${resb}" | cut -d'.' -f1)"
nameab="$(echo "${resab}" | cut -d'.' -f1)"
nameab_ts="$(echo "${resab_ts}" | cut -d'.' -f1)"

sed -r 's/\s+/,/g' "${resa}" > "${namea}".csv
#sed -r 's/\s+/,/g' "${resb}" > "${nameb}".csv
sed -r 's/\s+/,/g' "${resab}" > "${nameab}".csv
sed -r 's/\s+/,/g' "${resab_ts}" > "${nameab_ts}".csv
#three files as output from this script
