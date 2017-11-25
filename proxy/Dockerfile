FROM zeroman/base

RUN apt-get -qy --no-install-recommends install \
    iptables \
    procps \
    psmisc \
    redsocks \
    openssh-client

# RUN pip install shadowsocks==2.8.2
RUN pip install shadowsocks==2.4.3

ADD redsocks /root/

