FROM zeroman/x11

RUN apt-get install -y --no-install-recommends python python-pip python3 python3-pip libpython3-dev make \
        build-essential python-all-dev python-setuptools python-wheel python3-dev python3-setuptools python3-wheel \
        python3-venv

RUN update-alternatives --install /usr/bin/python python /usr/bin/python2 1 && \
        update-alternatives --install /usr/bin/python python /usr/bin/python3 2 && \
        update-alternatives --set python /usr/bin/python3


