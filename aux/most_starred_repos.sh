#!/bin/bash

echo .read schema.sql
echo .mode csv

for inf in commit_metadata,commits commit_files,files repository_info,repositories commit_parents,parents commit_repositories,commits_repositories
do
    d=`echo $inf | cut -f 1 -d,`
    n=`echo $inf | cut -f 2 -d,`
    for f in `ls $d`
    do
        echo .import "$d/$f" $n
    done
done



