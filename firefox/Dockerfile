FROM zeroman/x11

#RUN apt-get install -y --no-install-recommends iceweasel

RUN wget -O /tmp/setup "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=zh-CN" \
    && tar xvf /tmp/setup -C /opt \
    && ln -s /opt/firefox/firefox /usr/bin/firefox \
    && rm -fv /tmp/setup

ENV TZ=Asia/Hong_Kong

#RUN wget https://addons.mozilla.org/firefox/downloads/file/303844/selenium_ide-2.9.1-fx.xpi -O /root/selenium_ide.xpi
#RUN wget https://addons.mozilla.org/firefox/downloads/file/1699112/firex_proxy-5.2.5-fx.xpi -O /root/firex_proxy-5.2.5-fx.xpi
#RUN firefox --headless --install-global-extension /root/firex_proxy-5.2.5-fx.xpi

#RUN firefox --install-global-extension /root/selenium_ide.xpi
