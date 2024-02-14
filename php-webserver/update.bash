#!/bin/bash

set -e

PROJECT_PATH=$(dirname $0)
BASE_IMAGE=php:8-apache
WEB_IMAGE=webserver-web

rebuild() {
    cd $PROJECT_PATH
    docker compose down; docker compose up --build --detach
}

docker pull --quiet $BASE_IMAGE > /dev/null
if ! docker image ls | grep -q ^$WEB_IMAGE; then
    # image is missing -> built it and start container
    rebuild
    exit 0
fi

# check if container has to be rebuilt
TS_REF=$(docker image inspect --format='{{.Created}}' $BASE_IMAGE | xargs date +%s -d)
TS_WEB=$(docker image inspect --format='{{.Created}}' $WEB_IMAGE | xargs date +%s -d)
if [ $TS_REF -gt $TS_WEB ]; then
    # base image has updated -> rebuilt/restart web image
    rebuild
fi
