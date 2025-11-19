#!/bin/bash

PAPERLESS_USER=scanner
PAPERLESS_UID=$(getent passwd $PAPERLESS_USER | awk -F: '{ print $3 }')
if [ -z "$PAPERLESS_UID" ]; then
    echo "Cannot find UID for PAPERLESS_USER ($PAPERLESS_USER). Exiting."
    exit 1
fi

cd /volume1/paperless-ngx/ 2>/dev/null || { echo "Share paperless-ngx is missing. Please create it.."; exit 1; }

if [ ! -d incoming ]; then
    mkdir incoming
    chown $PAPERLESS_UID incoming
fi
if [ ! -d volumes ]; then
    mkdir volumes
    cd volumes
    mkdir data export media redis
    cd ..
    chown -R $PAPERLESS_UID volumes
fi

for password_file in db_password.txt db_root_password.txt; do
    if [ ! -e $password_file ]; then
        echo -n "$(dd if=/dev/random bs=12 count=1 2>&- | base64)" > $password_file
    fi
done

if [ ! -e docker-compose.yaml ]; then
    curl -sSLo docker-compose.yaml https://github.com/paperless-ngx/paperless-ngx/raw/refs/heads/dev/docker/compose/docker-compose.mariadb.yml
    sed -i '/PAPERLESS_DBPASS:/d' docker-compose.yml
fi

if [ ! -e docker-compose.env.orig ]; then
    curl -sSLo docker-compose.env.orig https://github.com/paperless-ngx/paperless-ngx/raw/refs/heads/dev/docker/compose/docker-compose.env
fi

if [ ! -e docker-compose.env ]; then
    curl -sSLo docker-compose.env https://gist.github.com/jamct/09514496da6263114b7ee4cd264ed8f7/raw/e788052233a5b955e46691521db86c9c246f525b/docker-compose.env
fi

if [ ! -e .env ]; then
    curl -sSLo .env https://github.com/paperless-ngx/paperless-ngx/raw/refs/heads/dev/docker/compose/.env
fi

if [ ! -e .paperless_secret.env ]; then
    {
        echo "PAPERLESS_SECRET_KEY=$(dd if=/dev/random bs=24 count=1 2>&- | base64)"
        #echo "PAPERLESS_DBPASS=$(cat db_password.txt)"
    } > .paperless_secret.env
fi

if [ ! -e .paperless_uid.env ]; then
    echo "USERMAP_UID=$PAPERLESS_UID" > .paperless_uid.env
fi

if [ ! -e docker-compose.override.yaml ]; then
    curl -sSLo docker-compose.override.yaml 'https://github.com/majes-git/docker/raw/refs/heads/master/paperless-ngx-ugreen/docker-compose.override.yaml'
fi
