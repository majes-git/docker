#!/bin/sh

TARGET_PATH=/srv/docker/containers/majes-git-docker/wireguard-ui-multi/

while true; do
    inotifywait -r -e create -e modify /data /sites.yaml
    for config in /data/*/config.json; do
        mkdir -p /tmp/$(dirname $config)
        sed -e 's/172.30/172.31/' $config > /tmp/$config
    done
    rsync -avz -e "ssh -p $SYNC_SSH_PORT" /tmp/data /sites.yaml $SYNC_TARGET:$TARGET_PATH
done
