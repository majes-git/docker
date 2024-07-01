#!/bin/bash

. $(dirname $0)/ldap.env

CONTAINER_NAME=nextcloud_app_1
CONFIG=/srv/docker/data-root/volumes/nextcloud_config/_data/config.php
USER_ID=33
OCC="docker exec -it -u $USER_ID $CONTAINER_NAME /var/www/html/occ"
SET_CONFIG="$OCC ldap:set-config s01"

while [ $(docker ps -q -f name=$CONTAINER_NAME | wc -l) -eq 0 ]; do
    echo "not running"
    sleep 1
done

if [ "$($OCC app:list --output=json_pretty | python3 -c 'import json; import sys; l = json.load(sys.stdin); print("user_ldap" in l["enabled"])')" = "False" ]; then
    # enable ldap plugin
    $OCC app:enable user_ldap
fi

if ! $OCC ldap:show-config s01 >/dev/null; then
    # add ldap config
    $OCC ldap:create-empty-config
    $SET_CONFIG ldapAgentName "$LDAP_AGENT_NAME"
    $SET_CONFIG ldapAgentPassword "$LDAP_AGENT_PASS"
    $SET_CONFIG ldapBase "$LDAP_BASE"
    $SET_CONFIG ldapBaseGroups "$LDAP_BASE"
    $SET_CONFIG ldapBaseUsers "$LDAP_BASE"
    $SET_CONFIG ldapHost "$LDAP_HOST"
    $SET_CONFIG ldapPort 636
    $SET_CONFIG turnOffCertCheck 1
    $SET_CONFIG ldapLoginFilter "$LDAP_LOGIN_FILTER"
    $SET_CONFIG ldapUserDisplayName "$LDAP_USER_DISPLAYNAME"
    $SET_CONFIG ldapUserFilter "$LDAP_USER_FILTER"
    $SET_CONFIG ldapGroupFilter "$LDAP_GROUP_FILTER"
    $SET_CONFIG hasMemberOfFilterSupport 1
    $SET_CONFIG ldapLoginFilterUsername 1
    $SET_CONFIG ldapExperiencedAdmin 1
    $SET_CONFIG ldapUserFilterMode 1
    $SET_CONFIG ldapConfigurationActive 1
fi

if ! grep skeletondirectory $CONFIG; then
    # add skeletondirectory to config.php
    sed -i "/);/i\ \ 'skeletondirectory' => ''," $CONFIG
fi
if ! grep default_language $CONFIG; then
    # add default_language to config.php
    sed -i "/);/i\ \ 'default_language' => 'de'," $CONFIG
fi
if ! grep default_locale $CONFIG; then
    # add default_locale to config.php
    sed -i "/);/i\ \ 'default_locale' => 'de_DE'," $CONFIG
fi
