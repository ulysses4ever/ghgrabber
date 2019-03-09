# this AWK script produces a CSV-like output with the hash of the commit, its
# subject, and its commit message all in one line
BEGIN {
    # example input format, hamsters indicate hashes
    #
    #    🐹 17a16fbed9a2765c38d768cbaa24efee211b8ff8
    #    Two more droplets.
    #
    #    🐹 a66b8f132d17b81ed864fbddde9841e49a40a263
    #    Merge branch 'master' of https://github.com/PRL-PRG/ghgrabber
    #
    #    🐹 205b156ca148b53d355a894d45918d4296f7639f
    #    Check progress on remote servers.
    #
    #    🐹 bc9df6bad596a4c36fa0487921e55a4a2f61e321
    #    Sequence creates its own directory if necessary.

    # format output so that fields are separated by commas, records are
    # separated by new lines
    OFS=",";
    ORS="\n";

    message[1] = "";
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

# auxiliary function. awk has no join...
function join(array, sep) {
    if (length(array) == 0)
        return "";

    if (length(array) == 1)
        return array[1];

    result = array[1]
    for (i = 2; i <= length(array); i++)
        result = result sep array[i]
    return result
}

# joins the contents of the buffer and prints it out along with the current
# hash
function aggregate_and_print() {
    #print "old hash: " hash " new hash: " $2 " message: " length(message)
    if (hash != "")
        print hash, quote(escape(join(message, "\n")));
}

$0 ~ /^🐹 .{40}$/ {
    # aggregate collected message chunks and print out commit info
    aggregate_and_print();

    # set new hash
    hash = $2

    # clear the buffer
    for (key in message) 
        delete message[key]

    # skip to next line
    next;
}

{
    # put line into the buffer
    l = length(message) + 1
    message[l] = $0
    #print "message[" l "] = " $0;
}

END {
    aggregate_and_print();
}
