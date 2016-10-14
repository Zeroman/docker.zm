FROM zeroman/java

# for build android application
RUN apt-get install -y --no-install-recommends \
        zlib1g:i386 abootimg aapt android-tools-adb \
        android-tools-fsutils android-tools-fastboot \
        pciutils mesa-utils

# for build android system
RUN apt-get install -y --no-install-recommends \
        squashfs-tools gettext python-mako genisoimage
# libgl1-mesa-dev 

RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

RUN echo "kvm:x:78:developer" >> /etc/group

# ADD android-studio.tar /opt/

USER developer

# CMD ["/opt/android-studio/bin/studio.sh"]


