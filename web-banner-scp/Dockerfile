FROM alpine
RUN apk add --update --no-cache openssh 
RUN adduser -h /var/www/html/banner -s /bin/sh -D -H banner && passwd -u banner
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 22
COPY entrypoint.sh /
