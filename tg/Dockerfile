FROM zeroman/x11

RUN apt-get install -y --no-install-recommends \
    apt-utils \
    dbus-x11 \
    dunst \
    hunspell-en-us \
    python3-dbus \
    software-properties-common \
    libx11-xcb1 \
    gconf2 \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


#ADD ./telegram.tar.xz /tmp/telegram.tar.xz

#RUN wget https://tdesktop.com/linux -O /tmp/telegram.tar.xz && \
    #cd /tmp/ && \
    #tar xvfJ /tmp/telegram.tar.xz && \
    #mv /tmp/Telegram/Telegram /usr/bin/Telegram && \
    #rm -rf /tmp/{telegram.tar.xz,Telegram} && \
    #rm /etc/fonts/conf.d/10-scale-bitmap-fonts.conf && \
    #fc-cache -fv

ADD ./Telegram/Telegram /usr/bin/Telegram

RUN echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && dpkg-reconfigure locales

ENV QT_XKB_CONFIG_ROOT /usr/share/X11/xkb

# Autorun Telegram
CMD ["/usr/bin/Telegram"]
