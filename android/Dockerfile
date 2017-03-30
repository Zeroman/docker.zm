FROM zeroman/java

# for build android application
RUN apt-get install -y --no-install-recommends -t jessie-backports \
        zlib1g:i386 abootimg aapt android-tools-adb \
        android-tools-fsutils android-tools-fastboot \
        pciutils mesa-utils squashfs-tools gettext python-mako genisoimage usbutils

# for build android system
# RUN apt-get install -y --no-install-recommends \
# libgl1-mesa-dev 

RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

RUN echo "kvm:x:78:developer" >> /etc/group

# ADD android-studio.tar /opt/

USER developer

# CMD ["/opt/android-studio/bin/studio.sh"]


