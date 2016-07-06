FROM zm.base

RUN apt-get install -y --no-install-recommends \
        zlib1g:i386 abootimg aapt android-tools-adb android-tools-fsutils android-tools-fastboot \
        sqlite openjdk-8-jdk

RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

ENTRYPOINT ["bash"]
