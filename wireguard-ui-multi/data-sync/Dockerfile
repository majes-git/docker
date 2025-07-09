FROM alpine:3

# Install
RUN apk --no-cache add inotify-tools openssh-client rsync tini

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
