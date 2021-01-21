FROM zeroman/x11

RUN apt-get install -y --no-install-recommends libnss3 libxss1 libasound2 desktop-file-utils libnotify4 xdg-utils libsecret-1-0 libappindicator3-1

ADD ./baidunetdisk_3.5.0_amd64.deb /tmp/setup.deb

RUN dpkg -i /tmp/setup.deb && rm -f /tmp/setup.deb

ENV TZ=Asia/Hong_Kong

CMD ["/opt/baidunetdisk/baidunetdisk"]
