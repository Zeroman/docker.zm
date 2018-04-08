FROM alpine 

RUN set -xe && apk add -U rsync && rm -rf /var/cache/apk/*

COPY rsyncd.* /etc/

VOLUME /share

EXPOSE 873 

CMD rsync --daemon --no-detach -vv --log-file /dev/stdout
