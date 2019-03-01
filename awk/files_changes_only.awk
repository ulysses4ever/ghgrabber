# Running:
# 
# git log --pretty=format:'%n"%H","%aN",%at,"%cN",%ct' --numstat --all | awk -f process.awk > wch_r-source_all_commits.csv
# 
# Or just for master branch:
#
# git log --pretty=format:'%n"%H","%aN",%at,"%cN",%ct' --numstat | awk -f process.awk > wch_r-source_master_only.csv

BEGIN {
    print "\"hash\",\"author\",\"author timestamp\",\"committer\",\"committer timestamp\",\"added lines\",\"deleted lines\",\"file path\"";  
    record = 1;
    metadata = "";
}

NR == 1 {
    next;
}

/^$/ {
    record = 1;
    if (modified_files == 0 && metadata != "") print metadata ",NA,NA,NA";
    next; 
}

record == 1 {
    metadata = $0
    record = record + 1;
    modified_files = 0;
    next;
}

/./ {
    split($0, statline, /[\t ]+/)
    print metadata "," statline[1] "," statline[2] ",\"" statline[3] "\"";
    modified_files = modified_files + 1;
    record = record + 1;
    next;
}
