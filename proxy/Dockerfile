FROM zeroman/base

RUN apt-get -qy --no-install-recommends install \
    iptables \
    procps \
    psmisc \
    redsocks \
    python-pip

RUN pip install shadowsocks==2.8.2

ADD redsocks /root/

CMD /root/redsocks

