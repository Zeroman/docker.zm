FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

ADD sources.list /etc/apt/sources.list

RUN dpkg --add-architecture i386 && apt-get update

RUN apt-get install -y --no-install-recommends -t jessie-backports \
        locales sqlite ca-certificates openssl apt-file lsof \
        sudo less tree file cpio patch wget curl rsync net-tools expect \
        xz-utils bzip2 zip unzip lzop p7zip p7zip-rar lzma lzop \
        bc procps kmod dosfstools dos2unix exfat-utils \
        make cmake gcc-multilib g++ gdb strace libncurses5-dev \
        distcc graphviz libpython-dev pkg-config automake autoconf \
        vim-nox git python python-pip cgvg cscope exuberant-ctags \
        xbase-clients fonts-wqy-microhei fonts-dejavu fonts-vlgothic \
        libglu1-mesa libegl1-mesa libglapi-mesa libgles1-mesa libgles2-mesa libopenvg1-mesa \
        libgl1-mesa-dri libegl1-mesa-drivers 

RUN apt-file update 

RUN pip install supervisor


ARG UID=1000
ARG GID=1000

RUN mkdir -p /home/developer && \
    echo "developer:x:${UID}:${GID}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${UID}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${UID}:${GID} -R /home/developer

RUN apt-get install -y --no-install-recommends -t jessie-backports distcc-pump


CMD ["supervisord"]
