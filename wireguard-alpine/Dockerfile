FROM alpine:latest
LABEL maintainer "Mathias Jeschke <mj@majes.de>"
RUN apk add --no-cache --update tini wireguard-tools
EXPOSE 51820/udp
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
