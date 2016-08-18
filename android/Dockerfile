FROM zeroman/java

RUN apt-get install -y --no-install-recommends \
        zlib1g:i386 abootimg aapt android-tools-adb \
        android-tools-fsutils android-tools-fastboot 

RUN apt-get install -y --no-install-recommends \
        pciutils mesa-utils

RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

RUN echo "kvm:x:78:developer" >> /etc/group

# ADD android-studio.tar /opt/

USER developer

# CMD ["/opt/android-studio/bin/studio.sh"]


