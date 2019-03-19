#!/bin/bash

printf ' %5s'    'chunk'
printf ' %15s'   'ip'
printf ' %24s'   'hostname'
printf ' %8s'    'duration'
printf ' %10s'    'projects'
printf ' %10s'   'rate [P/h]'
printf ' %10s'   'commits'
printf ' %10s'   'rate [C/s]'
printf ' %10s'   'files'
printf ' %10s'   'rate [F/s]'
printf ' %10s'   'data [MB]'
printf ' %11s'   'rate [MB/s]'
printf ' %10s'   'tar size'
printf '\n'



for line in `tail -n +2 "$1"`
do
    IFS=, read user host ip location chunk <<< $(echo "$line")

    ssh "${user}@${ip}" "\
        let DURATION_S=\$(( (\`tail -n1 $location/timing.csv | cut -f4 -d, | xargs -I{} echo {} / 1000 | bc\` \
                          -  \`head -n2 $location/timing.csv | tail -n1 | cut -f4 -d, | xargs -I{} echo {} / 1000 | bc\`) )); \
        let DURATION_H=\$(( DURATION_S / 3600 )); \
        let PROJECTS=\`tail -n +2 $location/timing.csv | wc -l\`; \
        let COMMITS=\`tail -n +2 $location/timing.csv | cut -f 7 -d , | awk '{SUM+=\$1;} END{print SUM}'\`; \
        let FILES=\`tail -n +2 $location/timing.csv | cut -f 8 -d , | awk '{SUM+=\$1;} END{print SUM}'\`; \
        let DATA=\`tail -n +2 $location/timing.csv | cut -f 9 -d , | awk '{SUM+=\$1;} END{print SUM}'\`; \
        printf ' %5s'    $chunk; \
        printf ' %15s'   $ip; \
        printf ' %24s'   \`hostname\`; \
        printf ' %8s'    \$DURATION_H; \
        printf ' %10s'   \$PROJECTS; \
        printf ' %10s'   \$((PROJECTS/DURATION_H)); \
        printf ' %10s'   \$COMMITS; \
        printf ' %10s'   \`bc <<< \"scale=2; \$COMMITS/\$DURATION_S\"\`; \
        printf ' %10s'   \$FILES; \
        printf ' %10s'   \`bc <<< \"scale=2; \$FILES/\$DURATION_S\"\`; \
        printf ' %10s'   \$((DATA/1024)); \
        printf ' %11s'   \`bc <<< \"scale=2; \$DATA/1024/\$DURATION_S\"\`; \
        printf '\n' " 
done

