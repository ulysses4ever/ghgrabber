#!/bin/bash

# $1 - repo.list
# $2 - timing.csv

temp_file=`mktemp`

<"$2" cut -f 2,3 -d, | tail -n +2 | \
while IFS=, read user repo
do 
    printf '%s/%s\n' $(eval echo "$user") $(eval echo "$repo")
done | \
sort | uniq >"$temp_file"

comm -12 <(sort "$1") "$temp_file" 
