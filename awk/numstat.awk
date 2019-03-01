# an AWK script that transforms the output of git-log into a CSV-like output
# containing the information about which file was modified by which commit and
# how
BEGIN {
    # expect the following record format:
    #
    #   ----$1:::$2
    #
    # where $1 is the hash of the commit and $2 is a multi-line description of
    # which files were modified by the commit and how, eg:
    #
    #   1 0   include/linux/interrupt.h
    #   4 0   kernel/irq/affinity.c
    #   8 5   kernel/irq/irqdesc.c
    #
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

# for each input record
{
    # first split the second field into separate lines
    split($2, stats, "\n");

    # then, for each line re-format its contents
    for (i in stats) {
        if (stats[i] ~ "^ *$") {
            # ignore empty lines
        } else {
            # split the statline into number of added lines, removed lines, and
            # the name of the file
            split(stats[i], statline, /[ \t]+/);

            # for each modified file output the hash of the commit, and the
            # stat info for the file
            print quote($1) , statline[1], statline[2], quote(escape(statline[3]));
        }
    }
}
