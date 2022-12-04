#!/bin/sh

# if dh file is empty, generate new parameters
DH_FILE=/etc/raddb/certs/dh
if [ ! -s $DH_FILE ]; then
    openssl dhparam -out $DH_FILE 1024
fi

# TODO: add sanity checks for TLS certs/key

# run incrond to monitor changes on authorize file and to reload radiusd
incrond

exec radiusd -f
