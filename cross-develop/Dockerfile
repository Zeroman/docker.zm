FROM zm.base

RUN apt-get install -y --no-install-recommends \
        nfs-kernel-server net-tools ckermit automake autoconf \
        tftp-hpa tftpd-hpa bc procps kmod dosfstools dos2unix \
        make gcc-multilib g++ libncurses5-dev u-boot-tools lzma lzop \
        cmake python libstdc++6-4.9-dbg lib32stdc++-4.9-dev lib32stdc++6-4.9-dbg zlib1g:i386 \
        tree file cgvg gdb valgrind mtd-utils exfat-utils sqlite lsof strace \
        cutils icheck cccc cppcheck cproto astyle indent highlight source-highlight sloccount expect graphviz \
        abootimg aapt android-tools-adb android-tools-fsutils android-tools-fastboot \
        cscope exuberant-ctags libpython-dev qt4-dev-tools default-jdk

ENV UID 1000

RUN mkdir -p -m 0777 /home/developer 

ADD cross_dev.sh /bin/cross_dev.sh

ENTRYPOINT ["/bin/cross_dev.sh"]
