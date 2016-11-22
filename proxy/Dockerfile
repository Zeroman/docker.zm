FROM zeroman/base

RUN apt-get -qy --no-install-recommends install \
    iptables \
    procps \
    psmisc \
    redsocks 

RUN pip install shadowsocks==2.8.2

ADD redsocks /root/

