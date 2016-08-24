# Dockerfile for pdnsd 

FROM alpine
MAINTAINER Zeroman <51feel@gmail.com>

RUN apk add -U pdnsd \
    && rm -rf /var/cache/apk/*

# EXPOSE 53/tcp 53/udp
ADD start_pdnsd /bin/

ENTRYPOINT ["start_pdnsd"]

