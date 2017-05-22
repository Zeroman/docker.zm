FROM zeroman/base

RUN apt-get install -y --no-install-recommends -t jessie-backports bridge-utils \
        zlib1g-dev liblzo2-dev libsnappy-dev libbz2-dev uuid-dev libaio-dev libusb-1.0-0-dev \
        librbd-dev libattr1-dev libcap-dev libglib2.0-dev libssl-dev libffi-dev \
        python-ironic-inspector libdrm-dev libgbm-dev libegl1-mesa-dev \
        libtool libpixman-1-dev libjpeg-dev libcacard-dev libsasl2-dev \
        libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev xutils-dev

# ENTRYPOINT ["bash"]
CMD ["bash"]
