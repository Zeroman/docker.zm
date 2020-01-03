FROM debian:stable

ENV DEBIAN_FRONTEND noninteractive

ADD sources.list /etc/apt/sources.list

RUN dpkg --add-architecture i386 \
        && apt-get update \
        && apt-get install -y --no-install-recommends bash vim curl zip unzip xz-utils bzip2 


RUN curl -fSL -o /tmp/test_linux.deb http://phoronix-test-suite.com/releases/repo/pts.debian/files/phoronix-test-suite_9.2.1_all.deb && \
        dpkg -i /tmp/test_linux.deb || true && apt --fix-broken install -y && rm -f /tmp/test_linux.deb \
        && mkdir -p /var/lib/phoronix-test-suite && mkdir -p /var/cache/phoronix-test-suite

RUN apt-get install -y --no-install-recommends build-essential autoconf bc bison flex libssl-dev mesa-utils apt-file

CMD bash
