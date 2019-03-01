# this AWK script produces a CSV-like output with the hash of the commit, its
# subject, and its commit message all in one line
BEGIN {
    # the input format is  specified as follows:
    #
    #   -----$1:::$2:::$3
    #
    # where $1 is a hash, $2 is a one-line 
    FS=":::"; 
    RS="-----"; 

    # format output so that fields are separated by commas, records are
    # separated by new lines
    OFS=",";
    ORS="\n";
} 

# auxiliary function to add quotes around strings
function quote(string) { return "\"" string "\"" }

# auxiliary function that reformats a string by escaping slashes, double
# quotes, and newlines
function escape(string) {
    gsub("\\", "\\\\", string);
    gsub("\n", "\\n", string);
    gsub("\"", "\\\"", string);
    return string
}

# for each input record, except the first line, which is garbage
NR > 1 {
    # reformat body and subject in three steps: replace slashes with double
    # slashes, escape newlines, and escape double quotes
    subject=escape($2);
    body=escape($3);
   
    # print out the line in quotes
    print quote($1), quote($2), quote(body);
}
