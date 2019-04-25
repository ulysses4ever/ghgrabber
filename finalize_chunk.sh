#!/bin/bash
take=ghtorrent

if [ -n "$1" ] 
then
    
    eval `ssh-agent` && \
    ssh-add ~/.ssh/id_rsa_cvut && \
    scp -o ProxyCommand="ssh prl1.ele.fit.cvut.cz nc 10.200.14.124 22" "data_${1}.tar.gz" "10.200.14.124:/array/dejavu/ghgrabber_distributed_take_${take}" && \
    rm -r "data_${1}"/{commit_comments,commit_file_hashes,commit_metadata,commit_parents,submodule_museum}

fi
