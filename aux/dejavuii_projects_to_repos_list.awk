function strip(s){
    sub("^\"", "", s)
    sub("\"$", "", s)
    return s
} 

BEGIN {
    FS=","
}

{
    print strip($2) "/" strip($3)
}
