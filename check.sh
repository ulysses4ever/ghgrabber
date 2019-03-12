#!/bin/bash

printf ' %4s'    '#'
printf ' %20s'   'ip'
printf ' %32s'   'hostname'
printf ' %10s'   'projects'
printf ' %10s'   'disk use%'
printf ' %32s' 'last download'
printf ' %8s'  'complete'
printf ' %8s\n'  'tarball?'
for line in `tail -n +2 "$1"`
do
    IFS=, read user host ip location chunk <<< $(echo "$line")
    ssh "${user}@${ip}" "printf ' %4s' $chunk; printf ' %20s' $ip; printf ' %32s' \`hostname\`\" \"; wc -l < \"$location/timing.csv\" | xargs printf ' %10s'; df -h . | tail -n 1 | tr -s ' ' | cut -f 5 -d ' ' | xargs printf ' %10s'; tail -n 1 \"$location\"/timing.csv | cut -f 4 -d , | xargs -I {} echo {} / 1000 | bc | TZ=Europe/Prague xargs -I{} date -d @{}  | xargs -I{} printf ' %32s ' {}; echo 100 \* '(' \$(< \"$location/timing.csv\" wc -l) - 1 ')' / \$(< \"$location/../repos/repos.list.$chunk\" wc -l) | bc | xargs printf '%8s%%'; test -e $location/../data_$chunk.tar.gz && echo '    true' || echo '   false'"
done

