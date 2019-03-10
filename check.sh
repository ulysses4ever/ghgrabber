#!/bin/bash

printf ' %20s'   'ip'
printf ' %32s'   'hostname'
printf ' %10s'   'projects'
printf ' %10s'   'disk use%'
printf ' %32s\n' 'last download'
for line in `tail -n +2 "$1"`
do
    IFS=, read user host ip location chunk <<< $(echo "$line")
    ssh "${user}@${ip}" "printf ' %20s' $ip; printf ' %32s' \`hostname\`\" \"; wc -l < \"$location/timing.csv\" | xargs printf ' %10s'; df -h . | tail -n 1 | tr -s ' ' | cut -f 5 -d ' ' | xargs printf ' %10s'; tail -n 1 \"$location\"/timing.csv | cut -f 4 -d , | TZ=Europe/Prague xargs -I{} date -d @{}  | xargs -I{} printf ' %32s\n' {}"
done

