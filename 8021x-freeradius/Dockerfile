FROM alpine:3

# Install
RUN apk --no-cache add freeradius freeradius-eap incron openssl tini

RUN sed -i -e '1,/default_eap_type/s/\(default_eap_type = \)md5/\1tls/' -e 's/\(use_tunneled_reply = \)no$/\1yes/' /etc/raddb/mods-available/eap

# inotify monitoring
RUN echo '/etc/raddb/mods-config/files/authorize IN_MODIFY /usr/bin/pkill -HUP radiusd' > /var/spool/incron/root

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
