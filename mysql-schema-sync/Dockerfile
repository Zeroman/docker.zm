FROM golang:alpine as builder

RUN apk add --no-cache git

RUN go get -u github.com/hidu/mysql-schema-sync

CMD mysql-schema-sync 2>/dev/null
