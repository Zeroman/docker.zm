FROM zm.base

RUN apt-get install -y --no-install-recommends \
        nfs-kernel-server ckermit tftp-hpa tftpd-hpa u-boot-tools  \
        libstdc++6-4.9-dbg lib32stdc++-4.9-dev lib32stdc++6-4.9-dbg zlib1g:i386 \
        cutils icheck cccc cppcheck cproto astyle indent highlight source-highlight \
        gdb valgrind mtd-utils sqlite qt4-dev-tools fakeroot 

ENV UID 1000

RUN mkdir -p -m 0777 /home/developer 

ADD cross_dev.sh /bin/cross_dev.sh

ENTRYPOINT ["/bin/cross_dev.sh"]
