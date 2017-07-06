#!/bin/sh
options=''
if [ -n "$1" ]; then
    options="--name $1"
fi

docker run -itd --cap-add=SYS_ADMIN -p 127.0.0.1:10022:22 $options local/centos7-work
