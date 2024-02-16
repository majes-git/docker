#!/bin/sh

# Generate sshd host keys if needed
ssh-keygen -A

# Disable password authentication
SSHD_CONF=/etc/ssh/sshd_config.d/01-no-password-auth.conf
if [ ! -e $SSHD_CONF ]; then
    echo 'PasswordAuthentication no' > $SSHD_CONF
fi

exec /usr/sbin/sshd -D -e "$@"
