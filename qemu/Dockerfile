FROM zeroman/archlinux

RUN pacman -S --needed --noconfirm qemu bridge-utils

ADD qemu.sh asus.bin bios.bin /opt/

ENTRYPOINT ["bash"]
