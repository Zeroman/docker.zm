FROM zm.archlinux

RUN pacman -S --needed --noconfirm qemu bridge-utils

ADD qemu.sh /usr/bin/

ENTRYPOINT ["bash"]
