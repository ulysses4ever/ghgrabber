@include "escape.awk"

BEGIN {
    FS="\n";
    RS="\n\n\n";
    OFS=",";
    ORS="\n";
}

{
    # 1: hash
    # 2: author email
    # 3: author time
    # 4: committer email
    # 5: committer time
    # 6: tag
    # 7: hamster
    print $1,quote_if_needed(escape($2)),quote_if_needed(escape($3)),quote_if_needed(escape($4)),quote_if_needed(escape($5)),quote_if_needed(escape($6)) 
}
