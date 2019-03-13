@include "escape.awk"

BEGIN {
    OFS=",";
    ORS="\n";

    # output header
    print quote("child"), quote("parent");
}

{
    for(i=2; i<=NF; i++) 
        print $1, $i;
}
