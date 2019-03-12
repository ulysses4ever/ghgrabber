# auxiliary function to add quotes around strings
function quote(string) { return "\"" string "\"" }

# auxiliary function that reformats a string by escaping slashes, double
# quotes, and newlines
function escape(string) {
    gsub(/\\/, "\\\\", string);
    gsub(/\n/, "\\n", string);
    gsub(/\"/, "\\\"", string);
    return string;
}

# auxiliary function. awk has no join...
function join(array, sep) {
    if (length(array) == 0)
        return "";

    if (length(array) == 1)
        return array[1];

    result = array[1]
    for (i = 2; i <= length(array); i++)
        result = result sep array[i];
    return result;
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
