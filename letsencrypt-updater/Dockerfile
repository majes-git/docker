FROM alpine

LABEL maintainer "Mathias Jeschke <mj@majes.de>"

# Install
RUN apk --no-cache add acme.sh dateutils tini

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
