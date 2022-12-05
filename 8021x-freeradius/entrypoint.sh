#!/bin/sh

# if dh file is empty, generate new parameters
DH_FILE=/etc/raddb/certs/dh
if [ ! -s $DH_FILE ]; then
    openssl dhparam -out $DH_FILE 1024
fi

# TODO: add sanity checks for TLS certs/key

# run inotifywait to monitor changes on authorize file and to reload radiusd
reload_radiusd() {
    while true; do
        inotifywait -e modify /etc/raddb/mods-config/files/authorize
        pkill -HUP radiusd
    done
}

reload_radiusd &
exec radiusd -f
