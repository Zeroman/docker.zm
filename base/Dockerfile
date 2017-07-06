FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive

ADD sources.list /etc/apt/sources.list

RUN dpkg --add-architecture i386 \
        && apt-get update \
        && apt-get install -y --no-install-recommends -t jessie-backports \
        locales sqlite ca-certificates openssl apt-file lsof \
        sudo less tree file cpio patch wget curl rsync net-tools expect \
        xz-utils bzip2 zip unzip lzop p7zip p7zip-rar lzma lzop \
        bc procps kmod dosfstools dos2unix exfat-utils \
        gcc-multilib g++-multilib make cmake gdb strace \
        graphviz pkg-config automake autoconf \
        vim-nox git cgvg distcc-pump distcc \
        python python-pip libpython-dev \
        libncurses5-dev:i386 zlib1g-dev:i386 \
        libncurses5-dev zlib1g-dev \
        lib32stdc++6-4.9-dbg libx32stdc++6-4.9-dbg \
        && apt-file update \
        && pip install supervisor

ARG UID=1000
ARG GID=1000

RUN mkdir -p /home/developer && \
    echo "developer:x:${UID}:${GID}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${UID}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${UID}:${GID} -R /home/developer

# RUN apt-get install -y --no-install-recommends -t jessie-backports \


CMD ["supervisord"]
