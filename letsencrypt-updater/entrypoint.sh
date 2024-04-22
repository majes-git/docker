#!/bin/sh

: ${LE_WORKING_DIR:=/letsencrypt}
: ${DAILY_TIME:=01:00}
: ${DNS_API:=dns_autodns}
: ${RENEW_DAYS:=15}

if [ -z "$DOMAIN" ]; then
    echo "Environment variable DOMAIN must be specified!"
    exit 1
fi

cert_file=/letsencrypt/${DOMAIN}_ecc/${DOMAIN}.cer

get_cert() {
    acme.sh --$1 --server letsencrypt --home $LE_WORKING_DIR --dns $DNS_API -d $DOMAIN -d "*.$DOMAIN"
    (cd /letsencrypt/${DOMAIN}_ecc/; cat ${DOMAIN}.key > privkey.pem)
}

while : ; do
    if [ -e $cert_file ]; then
        if ! openssl x509 -checkend $(expr 86400 \* $RENEW_DAYS) -in $cert_file >/dev/null; then
            # cert will expire in the next $RENEW_DAYS days
            get_cert renew
        fi
    else
        get_cert issue
    fi

    # calculate next check time
    now=$(date '+%s')
    next_check=$(date -d "$(dateadd today +1d) $DAILY_TIME" '+%s')

    # wait until next check
    sleep $(($next_check - $now))
done
