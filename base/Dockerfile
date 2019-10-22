FROM debian:stable

ENV DEBIAN_FRONTEND noninteractive

ADD sources.list /etc/apt/sources.list

RUN dpkg --add-architecture i386 \
        && apt-get update \
        && apt-get install -y --no-install-recommends \
        locales sqlite3 ca-certificates openssl apt-file lsof gnupg2 \
        sudo less tree file cpio patch wget curl rsync net-tools expect gawk \
        xz-utils bzip2 zip unzip lzop p7zip p7zip-rar lzma lzop \
        bc procps kmod dosfstools dos2unix exfat-utils \
        gcc-multilib g++-multilib make cmake gdb strace \
        graphviz pkg-config automake autoconf \
        vim-nox git cgvg \
        python libpython-dev python3 libpython3-dev \
        libncurses5-dev:i386 zlib1g-dev:i386 \
        libncurses5-dev zlib1g-dev lsb-release \
        && apt-file update 

RUN apt-get install -y --no-install-recommends \
        python-pip python-wheel python-setuptools \
        python3-pip python3-setuptools \
        && pip install -U supervisor 

# lib32stdc++6-4.9-dbg libx32stdc++6-4.9-dbg \

ARG UID=1000
ARG GID=1000

ENV LANG C.UTF-8

RUN groupadd -g $GID developer && useradd -u $UID -g $GID developer && echo "developer:developer" | chpasswd && \
    mkdir -p /home/developer && chown -R developer:developer /home/developer && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer 

# RUN apt-get install -y --no-install-recommends -t jessie-backports \


CMD ["supervisord"]
