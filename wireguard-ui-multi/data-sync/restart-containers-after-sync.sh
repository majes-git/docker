#!/bin/sh

exec >> /tmp/data-sync.log
exec 2>&1

cd $(dirname $0)/..

for config in $(cd data; ls); do
    started=$(docker container inspect -f '{{ .State.StartedAt }}' wireguard-ui-multi-$config-1 | xargs date +%s -d)
    changed=$(stat -c %Y data/$config/config.json)
    if [ $started -lt $changed ]; then
        echo $(date '+%Y-%m-%d %H:%M:%S') $config has changed - restarting container
        docker compose restart $config
    fi
done
