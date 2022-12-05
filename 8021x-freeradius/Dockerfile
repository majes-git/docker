FROM alpine:3

# Install
RUN apk --no-cache add freeradius freeradius-eap inotify-tools openssl tini

RUN sed -i -e '1,/default_eap_type/s/\(default_eap_type = \)md5/\1tls/' -e 's/\(use_tunneled_reply = \)no$/\1yes/' /etc/raddb/mods-available/eap

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
