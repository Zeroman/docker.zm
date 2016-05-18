FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

ADD sources.list /etc/apt/sources.list

RUN dpkg --add-architecture i386 && apt-get update 

RUN apt-get install -y --no-install-recommends \
        sudo vim-nox git less tree file xz-utils bzip2 unzip lzop \
        xbase-clients fonts-wqy-microhei fonts-dejavu fonts-vlgothic
