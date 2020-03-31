FROM zeroman/x11

RUN apt-get install -y --no-install-recommends libnss3 libxss1 libasound2 desktop-file-utils

ADD ./baidunetdisk_linux_3.0.1.2.deb /tmp

RUN dpkg -i /tmp/baidunetdisk_linux_3.0.1.2.deb && rm -f /tmp/baidunetdisk_linux_3.0.1.2.deb

ENV TZ=Asia/Hong_Kong

ENTRYPOINT ["/opt/baidunetdisk/baidunetdisk"]
