#!/bin/bash

. /etc/renew-certificates.conf

: ${DOMAIN:=example.com}
: ${TLS_DIR:=/etc/tls}
: ${WEB_USER:=admin}
: ${WEB_PASS:=secret}
: ${WEB_URL:="https://${WEB_USER}:${WEB_PASS}@letsencrypt-certs.${DOMAIN}/${DOMAIN}_ecc"}
: ${RENEW_DAYS:=10}

cert_file=$TLS_DIR/fullchain.pem
if [ -e $cert_file ]; then
    if openssl x509 -checkend $(expr 86400 \* $RENEW_DAYS) -in $cert_file >/dev/null; then
        # cert will not expire in the next $days days
        exit 0
    fi
fi

curl -s -o $TLS_DIR/fullchain.pem $WEB_URL/fullchain.cer
curl -s -o $TLS_DIR/privkey.pem $WEB_URL/privkey.pem

. /usr/local/sbin/renew-certificates-post.bash
