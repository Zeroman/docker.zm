FROM zeroman/qt

#RUN apt-get install -y --no-install-recommends qt5-default libqt5webchannel5 libqt5x11extras5

ADD sources.list /etc/apt/sources.list

ENV TZ=Asia/Hong_Kong

RUN wget https://repo.debiancn.org/pool/main/d/debiancn-keyring/debiancn-keyring_0~20161212_all.deb -O /tmp/debiancn-keyring.deb && \
        apt install /tmp/debiancn-keyring.deb && apt update && rm -f /tmp/debiancn-keyring.deb

RUN apt-get install -y netease-cloud-music

CMD ["netease-cloud-music"]
