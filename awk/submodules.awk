@include "escape.awk"

# an AWK script that transforms the output of git-log --follow into a simple
# output that can be fed to xargs to retrieve the contents of the file at
# specific times
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

    # output header
    if (header) {
        print quote("commit hash"), quote("file hash");
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

            print $1, statline[4]
        }
    }
}
