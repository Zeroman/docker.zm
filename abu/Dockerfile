FROM zeroman/x11

RUN apt-get install -y --no-install-recommends \
        python3 python3-dev sqlite3 python3-pip python3-setuptools \
        libcurl4-openssl-dev libffi-dev libsqlite3-dev libzmq3-dev pandoc \
        texlive-fonts-recommended texlive-latex-base texlive-latex-extra \
        python3-ipykernel python3-ipywidgets python3-widgetsnbextension python3-notebook \
        jupyter-core jupyter-notebook

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && dpkg-reconfigure locales
ENV LANG zh_CN.UTF-8  
ENV LANGUAGE zh_CN:zh  
ENV LC_ALL zh_CN.UTF-8

EXPOSE 8888

RUN pip3 install --no-cache-dir seaborn statsmodels bokeh toolz sklearn psutil requests

RUN apt-get install -y --no-install-recommends \
        python3-pil

USER developer

CMD sh -c 'jupyter notebook --ip=0.0.0.0 --no-browser'

