#!/bin/bash

function escape_quotes {
    echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

function download_repo_contents {
    local destination=$(mktemp --directory)
    GIT_TERMINAL_PROMPT=0 git clone "https://github.com/$1/$2.git" "$destination"
    #git clone "ssh://git@github.com/$1/$2.git" "$destination"
    echo "$destination"
}

function retrieve_commit_metadata {
    echo '"hash","author name","author email","author timestamp","committer name","committer email","committer timestamp","tag"'
    git log --pretty=format:'"%H","%an","%ae","%at","%cn","%ce","%ct","%s","%D"' --all 
}

function retrieve_commit_file_modification_info {
    echo '"hash","added lines","deleted lines","file"'
    git log --pretty=format:-----%H:::  --numstat --all | \
        awk -f "${home}/awk/numstat.awk"
}


function retrieve_commit_comments {
    echo '"hash","topic","message"'
    git log --pretty=format:"-----%H:::%s:::%B"  --all | \
        awk -f "${home}/awk/comment.awk"
}

function retrieve_commit_parents {
    echo '"child","parent"'
    git log --pretty=format:"%H %P" | \
        awk '{for(i=2; i<=NF; i++) print "\""$1"\",\""$i"\""}'
}

function retrieve_commit_repositories {
    echo '"hash","id"'
    git log --pretty=format:"\"%H\",$1"
}

function retrieve_repository_info {
    echo '"id","user","project"'
    echo "${3},\"${1}\",\"${2}\""
}

function prepare_directories {
    mkdir -p "$OUTPUT_DIR/commit_metadata"
    mkdir -p "$OUTPUT_DIR/commit_files"
    mkdir -p "$OUTPUT_DIR/commit_comments"
    mkdir -p "$OUTPUT_DIR/commit_parents"
    mkdir -p "$OUTPUT_DIR/commit_repositories"
    mkdir -p "$OUTPUT_DIR/repository_info"
}

function process_repository {
    local user="$1"
    local repo="$2"
    local i="$3"

    local filename="${user}_${repo}.csv"

    local repository_path="$(download_repo_contents $user $repo)"
    cd "${repository_path}"

    retrieve_commit_metadata                > "$OUTPUT_DIR/commit_metadata/${filename}"
    retrieve_commit_file_modification_info  > "$OUTPUT_DIR/commit_files/${filename}"
    retrieve_commit_comments                > "$OUTPUT_DIR/commit_comments/${filename}"
    retrieve_commit_parents                 > "$OUTPUT_DIR/commit_parents/${filename}"
    retrieve_commit_repositories $i         > "$OUTPUT_DIR/commit_repositories/${filename}"
    retrieve_repository_info $user $repo $i > "$OUTPUT_DIR/repository_info/${filename}"

    cd "$home"

    if expr ${repository_path} : '/tmp/tmp\...........' >/dev/null
    then
        echo "Removing '${repository_path}'"
        rm -rf "${repository_path}"
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

function use_first_if_available {
    [ -n "$1" ] && echo "$1" || echo "$2"
}

echo 'Hi!'

REPOS_LIST=`use_first_if_available "$1" "repos.list"`
OUTPUT_DIR=`use_first_if_available "$2" "data"`
home="$(pwd)"

if expr "$OUTPUT_DIR" : "^/" >/dev/null 
then 
    :
else 
    OUTPUT_DIR="$home/$OUTPUT_DIR"
fi

echo "Downloading repos from '$REPOS_LIST' to '$OUTPUT_DIR'"

prepare_directories
echo '"user","repo","time"' > timing.csv

i=0
for info in `cat "$REPOS_LIST"`
do
    i=$(( $i + 1 ))

    if [ -e "STOP" ]
    then
        echo "detected STOP file, stopping"
        break
    fi

    echo processing $i $info

    user=$(echo $info | cut -f1 -d/)
    repo=$(echo $info | cut -f2 -d/)
    
    start_time=$(date +%s)
    process_repository $user $repo $i
    end_time=$(date +%s)
    echo "\"${user}\"","\"${repo}\"",$(print_time $((end_time - start_time))) \
        >> "$OUTPUT_DIR/timing.csv"
done

