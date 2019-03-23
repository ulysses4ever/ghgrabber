#!/bin/bash

if [ -n "$1" ]
then

    time ./grab.sh "repos/repos.list.${1}" "data_${1}" 4
fi
