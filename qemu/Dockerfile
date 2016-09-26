FROM zeroman/base

RUN apt-get install -y --no-install-recommends -t jessie-backports bridge-utils qemu-system-x86 qemu-kvm

ADD qemu.sh asus.bin bios.bin /opt/

ENTRYPOINT ["/opt/qemu.sh"]
