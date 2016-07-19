FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

ADD sources.list /etc/apt/sources.list

RUN dpkg --add-architecture i386 && apt-get update 

RUN apt-get install -y --no-install-recommends \
        sudo vim-nox git less tree file xz-utils bzip2 unzip lzop \
        xbase-clients fonts-wqy-microhei fonts-dejavu fonts-vlgothic \
        bc procps kmod dosfstools dos2unix make gcc-multilib g++ libncurses5-dev \
        expect graphviz cscope exuberant-ctags libpython-dev sloccount \
        lzma lzop cmake python tree file cgvg exfat-utils lsof strace \
        patch wget cpio rsync net-tools automake autoconf curl unzip \
        default-jdk locales
