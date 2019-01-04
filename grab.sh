#!/bin/bash

function download_repo_contents {
    local destination=$(mktemp --directory)
    git clone "https://github.com/$1/$2.git" "$destination"
    echo "$destination"
}

function retrieve_commit_metadata {
    echo '"hash","author name","author email","author timestamp","committer name","committer email","committer timestamp"'
    git log --pretty=format:'"%H","%an","%ae","%ad","%cn","%ce","%ct"' --all
}

function retrieve_commit_file_modification_info {
    echo '"hash","added lines", "deleted lines", "file"'
    git log --pretty=format:-----%H:::  --all --numstat | awk -f "${home}/numstat.awk"
}

function retrieve_commit_comments {
    echo '"hash","topic","message"'
    git log --pretty=format:"-----%H:::%s:::%B"  --all | awk -f "${home}/comment.awk"
}

function prepare_directories {
    home="$(pwd)"
    mkdir -p commit_metadata
    mkdir -p commit_files
    mkdir -p commit_comments
}


function process_repository {
    local user="$1"
    local repo="$2"

    local filename="${user}_${repo}.csv"

    local repository_path="$(download_repo_contents $user $repo)"
    cd "${repository_path}"

    retrieve_commit_metadata > "${home}/commit_metadata/${filename}"
    retrieve_commit_file_modification_info > "${home}/commit_files/${filename}"
    retrieve_commit_comments > "${home}/commit_comments/${filename}"

    cd "$home"
}

function print_time {
    local time="$1"

    local hours=$((time/60/60))
    local minutes=$(((time/60)%60))
    local seconds=$((time%60))

    local sec_extra_zero=`((seconds > 9)) && echo -n "" || echo -n 0`
    local min_extra_zero=`((minutes > 9)) && echo -n "" || echo -n 0`

    echo ${hours}:${min_extra_zero}${minutes}:${sec_extra_zero}${seconds}
}

prepare_directories
echo '"user","repo","time"' > timing.csv
for info in `cat repos.list`
do
    echo processing $info

    user=$(echo $info | cut -f1 -d/)
    repo=$(echo $info | cut -f2 -d/)
    
    start_time=$(date +%s)
    process_repository $user $repo
    end_time=$(date +%s)
    echo "\"${user}\"","\"${repo}\"",$(print_time $((end_time - start_time))) >> timing.csv
done
 
