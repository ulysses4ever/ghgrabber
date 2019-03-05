#!/bin/bash

# split off the last N lines from a file into a copy

original_file="$1"
file_head="${1}.head"
file_tail="${1}.tail"

head -n -"$2" $original_file > $file_head
tail -n "$2" $original_file > $file_tail
