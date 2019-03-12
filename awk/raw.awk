# an AWK script that transforms the output of git-log into a CSV-like output
# containing the information about which file was modified by which commit and
# specifically provides source and target hashes
BEGIN {
    # Input format example
    #
    # 6862fbc6553db1e25f28c3e391189627835390fb
    # 
    # :100644 000000 c861ffa9ae998c50c982d5432cdaa0eb27738c1c 0000000000000000000000000000000000000000 D      api_grab.r
    # :100755 000000 8b659d68277ec8417116cbb8865900db5a065675 0000000000000000000000000000000000000000 D      comment.awk
    # :100644 000000 1f284d5ce2ec0cadc21a13228b2bf088f603311f 0000000000000000000000000000000000000000 D      files_changes_only.awk
    # :100644 000000 d9bd25814d36d1efbb53ed00f6ee0b462405f329 0000000000000000000000000000000000000000 D      githubapi.r
    # :100755 100755 09f1b7326254f00ff98c2426c9fc64dbc1652502 aac139e1ffd50ccbebd59a2192956ede10229e02 M      grab.sh
    # :100755 000000 0579880c328da8c2b80dc128164f574b1bca1211 0000000000000000000000000000000000000000 D      numstat.awk
    # :100644 000000 14f84e205c296e705c26f1a541c1c72830787b89 0000000000000000000000000000000000000000 D      retrieve_starred_repos.r
    # :100644 000000 b1755b53d248aa65d144eca3e102e1420ac2a22b 0000000000000000000000000000000000000000 D      schema.sql
    # :100644 100644 de03518b6444cff4d9238663edf2cc81e59efd63 f21fad67b78973ee6e82766a3f5e1635275ea261 R071   test/child-process-follows.js   test/child-process-follow.js
    #
    FS="\n\n";
    RS="\n\n\n"; 
    # so basically we're getting $1=hash, $2=all the changes, and then we can
    # split $2 by \n to get individual files

    # format output so that fields are separated by commas, records are
    # separated by new lines
    OFS=",";
    ORS="\n";
} 

# auxiliary function to add quotes around strings
function quote(string) { return "\"" string "\""; }

# auxiliary function that reformats a string by escaping slashes, double
# quotes, and newlines
function escape(string) {
    gsub("\\", "\\\\", string);
    gsub("\n", "\\n", string);
    gsub("\"", "\\\"", string);
    return string;
}

# auxiliary function thta checks whether a string is surrounded by quotes
function is_quoted(string) {
    return match(string, /^\".*\"$/);
}

# auxiliary function to add quotes around strings, but only if the string is
# not already quoted
function quote_if_needed(string) {
    if (string == "") {
        return "";
    } if (is_quoted(string) == 0) {
        return quote(string);
    } else {
        return string;
    }
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
            # split the statline into columns: statline, filename1, filename2, where
            # statline contains information about what was changed in the file;
            # in most cases filename1 is the name of the file and filename2 is
            # empty; if the file is moved or copied filename1 is the old name of
            # the file, and filename2 is the new name of the file.
            split(stats[i], columns, /[\t]+/);

            # the first column should contain the changes to the file
            # regardless of the situation, so it needs to be split. might as
            # well write it once.
            split(columns[1], statline, / +/);

            # something went seriously wrong
            if (length(statline) != 5) {
                print $1, "", "", "", "", "# FORMAT ERROR: " length(statline) " fields";
            }

            # this means that we have just one file name, the classic case
            if (length(columns) == 2) {
                print $1, statline[4], quote_if_needed(statline[5]), quote_if_needed(columns[2]), "";
            # this means we have a rename or copy situation where there is an old name and then a new name
            } else if (length(columns) == 3) {
                print $1, statline[4], quote_if_needed(statline[5]), quote_if_needed(columns[3]), quote_if_needed(columns[2]);
            # this means something is seriously wrong
            } else {
                print $1, statline[4], quote_if_needed(statline[5]), "" , "", "# FORMAT ERROR: " length(columns) " fields";
            } 
        }
    }
}
