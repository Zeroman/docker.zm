FROM debian:stable

ENV DEBIAN_FRONTEND noninteractive

ADD sources.list /etc/apt/sources.list

RUN dpkg --add-architecture i386 \
        && apt-get update \
        && apt-get install -y --no-install-recommends \
        locales ca-certificates openssl apt-file lsof gnupg2 \
        sudo less tree file cpio patch wget curl rsync net-tools expect gawk \
        xz-utils bzip2 zip unzip lzop p7zip p7zip-rar lzma lzop \
        bc procps kmod dosfstools dos2unix exfat-utils \
        vim-nox git cgvg python libpython-dev  \
        && apt-file update 

ARG UID=1000
ARG GID=1000

ENV LANG C.UTF-8

RUN groupadd -g $GID user && useradd -u $UID -g $GID user && echo "user:user" | chpasswd && \
    mkdir -p /home/user && chown -R user:user /home/user && \
    echo "user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user 


CMD ["bash"]
