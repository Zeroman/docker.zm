FROM zeroman/x11

RUN apt-get install -y --no-install-recommends iceweasel

RUN wget https://addons.mozilla.org/firefox/downloads/file/303844/selenium_ide-2.9.1-fx.xpi -O /root/selenium_ide.xpi

RUN firefox --install-global-extension /root/selenium_ide.xpi
