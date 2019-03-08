#!/bin/bash

for line in `tail -n +2 "$1"`
do
    IFS=, read user host location <<< $(echo "$line")
    ssh "${user}@${host}" "echo -n \`hostname\`\" \"; wc -l < \"$location\""
done

