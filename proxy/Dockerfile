FROM zm.base

RUN apt-get -qy --no-install-recommends install \
    iptables \
    procps \
    psmisc \
    redsocks
    
ADD redsocks /root/

ENTRYPOINT ["/bin/bash", "/root/redsocks"]

