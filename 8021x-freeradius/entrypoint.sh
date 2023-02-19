#!/bin/sh

# if dh file is empty, generate new parameters
DH_FILE=/etc/raddb/certs/dh
if [ ! -s $DH_FILE ]; then
    openssl dhparam -out $DH_FILE 1024
fi

# TODO: add sanity checks for TLS certs/key
# openssl verify -insecure /etc/raddb/certs/ca.pem /etc/raddb/certs/server.pem

install_tls() {
    cat /etc/letsencrypt/live/*/privkey.pem /etc/letsencrypt/live/*/cert.pem > /etc/raddb/certs/server.pem
    cat /etc/letsencrypt/live/*/chain.pem > /etc/raddb/certs/ca.pem
}

# run inotifywait to monitor TLS changes and to reload radiusd
reload_tls() {
    while true; do
        inotifywait -r -e create -e modify /etc/letsencrypt/archive
        install_tls
	touch /tmp/restart_radiusd
        pkill -TERM radiusd
    done
}

# run inotifywait to monitor changes on authorize file and to reload radiusd
reload_radiusd() {
    while true; do
        inotifywait -e modify /etc/raddb/mods-config/files/authorize
        pkill -TERM radiusd
    done
}


install_tls
reload_radiusd &
reload_tls &
while true; do
    radiusd -f -X
    if [ ! -e /tmp/restart_radiusd ]; then exit 0; fi
    rm /tmp/restart_radiusd
done
