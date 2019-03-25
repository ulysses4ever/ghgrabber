#!/bin/bash

printf ' %5s'    'chunk'
printf ' %15s'   'ip'
printf ' %24s'   'hostname'
printf ' %8s'    'user'
printf ' %9s'    'processes'
printf ' %10s'   'downloaded'
printf ' %6s'    'to do'
printf ' %6s'    '% done'
printf ' %20s'   'started'
printf ' %20s'   'last download'
printf ' %8s'    'duration'
printf ' %8s'   'd/l rate'
printf ' %10s'   '% disk use'
printf '\n'



for line in `tail -n +2 "$1"`
do
    IFS=, read user host ip location chunk <<< $(echo "$line")
    #ssh "${user}@${ip}" "printf ' %4s' $chunk; printf ' %20s' $ip; printf ' %32s' \`hostname\`\" \"; wc -l < \"$location/timing.csv\" | xargs printf ' %10s'; df -h . | tail -n 1 | tr -s ' ' | cut -f 5 -d ' ' | xargs printf ' %10s'; tail -n 1 \"$location\"/timing.csv | cut -f 4 -d , | xargs -I {} echo {} / 1000 | bc | TZ=Europe/Prague xargs -I{} date -d @{}  | xargs -I{} printf ' %32s ' {}; echo 100 \* '(' \$(< \"$location/timing.csv\" wc -l) - 1 ')' / \$(< \"$location/../repos/repos.list.$chunk\" wc -l) | bc | xargs printf '%8s%%'; test -e $location/../data_$chunk.tar.gz && echo '    true' || echo '   false'"


    ssh "${user}@${ip}" "\
        DOWNLOADED=\$(tail -n +2 $location/timing.csv | wc -l); \
        TODO=\$(< $location/../repos/repos.list.$chunk wc -l); \
        PERCENT_DONE=\$(echo 100 \* \$DOWNLOADED / \$TODO | bc); \
        START_TIMESTAMP=\$(head -n2 $location/timing.csv | tail -n1 | cut -f4 -d, | xargs -I{} echo {} / 1000 | bc); \
        START_TIME=\"\$(echo \$START_TIMESTAMP | TZ=Europe/Prague xargs -I{} date -d @{} +'%d/%m/%y %H:%M:%S')\"; \
        END_TIMESTAMP=\$(tail -n1 $location/timing.csv | cut -f4 -d, | xargs -I{} echo {} / 1000 | bc); \
        END_TIME=\"\$(echo \$END_TIMESTAMP | TZ=Europe/Prague xargs -I{} date -d @{} +'%d/%m/%y %H:%M:%S')\"; \
        ELAPSED_TIME=\$(( \$END_TIMESTAMP - \$START_TIMESTAMP )); \
        ELAPSED_TIME_H=\$(( \$ELAPSED_TIME / 3600 )); \
        if (( \$ELAPSED_TIME_H > 0 )); \
        then DOWNLOAD_RATE=\$(( \$DOWNLOADED / \$ELAPSED_TIME_H )); \
        else DOWNLOAD_RATE=\$DOWNLOADED; \
        fi; \
        printf ' %5s'   $chunk; \
        printf ' %15s'  $ip; \
        printf ' %24s'  \`hostname\`; \
        printf ' %8s'   \`whoami\`; \
        printf ' %9s'   4; \
        printf ' %10s'  \$DOWNLOADED; \
        printf ' %6s'   \$TODO; \
        printf ' %5s%%' \$PERCENT_DONE; \
        printf ' %20s'  \"\$START_TIME\"; \
        printf ' %20s'  \"\$START_TIME\"; \
        printf ' %8s'   \$ELAPSED_TIME_H; \
        printf ' %8s'   \"\$DOWNLOAD_RATE\"; \
        printf ' %10s'  \`df -h . | tail -n 1 | tr -s ' ' | cut -f5 -d' '\` ;\
        printf '\n' " 
done

