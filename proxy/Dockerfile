FROM zeroman/base

RUN apt-get -qy --no-install-recommends install \
    iptables \
    procps \
    psmisc \
    redsocks \
    openssh-client \
    libsodium-dev

# RUN pip install shadowsocks==2.8.2
# RUN pip install shadowsocks==2.4.3
#RUN pip --no-cache-dir install https://github.com/shadowsocksr-backup/shadowsocksr/archive/manyuser.zip 

ADD redsocks /root/

