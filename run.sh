#!/bin/bash
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
./start_chunk.sh $1 && ./finalize_chunk.sh $1


