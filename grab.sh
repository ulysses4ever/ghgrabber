#!/bin/bash

function download_repo_contents {
    local destination=$(mktemp --directory)
    git clone "https://github.com/$1/$2.git" "$destination"
    echo "$destination"
}

function retrieve_commit_metadata {
    echo '"hash","author name","author email","author timestamp","committer name","committer email","committer timestamp"'
    git log --pretty=format:'"%H","%an","%ae","%at","%cn","%ce","%ct"' --all 
}

function retrieve_commit_file_modification_info {
    echo '"hash","added lines", "deleted lines", "file"'
    git log --pretty=format:-----%H:::  --numstat --all | \
        awk -f "${home}/numstat.awk"
}

function retrieve_commit_comments {
    echo '"hash","topic","message"'
    git log --pretty=format:"-----%H:::%s:::%B"  --all | \
        awk -f "${home}/comment.awk"
}

function retrieve_commit_parents {
    echo '"child","parent"'
    git log --pretty=format:"%H %P" | awk '{for(i=2; i<=NF; i++) print "\""$1"\",\""$i"\""}'
}

function retrieve_commit_repositories {
    echo '"hash","id"'
    git log --pretty=format:"\"%H\",$1"
}

function retrieve_repository_info {
    echo '"id", "user", "project"'
    echo "${3},\"${1}\",\"${2}\""
}

function prepare_directories {
    home="$(pwd)"
    mkdir -p data/commit_metadata
    mkdir -p data/commit_files
    mkdir -p data/commit_comments
    mkdir -p data/commit_parents
    mkdir -p data/commit_repositories
    mkdir -p data/repository_info
}

function process_repository {
    local user="$1"
    local repo="$2"
    local i="$3"

    local filename="${user}_${repo}.csv"

    local repository_path="$(download_repo_contents $user $repo)"
    cd "${repository_path}"

    retrieve_commit_metadata                > "${home}/data/commit_metadata/${filename}"
    retrieve_commit_file_modification_info  > "${home}/data/commit_files/${filename}"
    retrieve_commit_comments                > "${home}/data/commit_comments/${filename}"
    retrieve_commit_parents                 > "${home}/data/commit_parents/${filename}"
    retrieve_commit_repositories $i         > "${home}/data/commit_repositories/${filename}"
    retrieve_repository_info $user $repo $i > "${home}/data/repository_info/${filename}"

    cd "$home"

    if expr ${repository_path} : '/tmp/tmp\...........' >/dev/null
    then
        rm -rfv "${repository_path}"
    fi
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

echo 'Hi!'

prepare_directories
echo '"user","repo","time"' > timing.csv

i=0
for info in `cat repos.list`
do
    i=$(( $i + 1 ))

    echo processing $i $info

    user=$(echo $info | cut -f1 -d/)
    repo=$(echo $info | cut -f2 -d/)
    
    start_time=$(date +%s)
    process_repository $user $repo $i
    end_time=$(date +%s)
    echo "\"${user}\"","\"${repo}\"",$(print_time $((end_time - start_time))) \
        >> timing.csv
done


