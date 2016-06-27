FROM zm.base


RUN apt-get install -y --no-install-recommends locales ca-certificates \
        wine-development wine32-development wine32-development-preloader fonts-wine

RUN echo "zh_CN.GBK GBK" > /etc/locale.gen && locale-gen
ENV LC_ALL zh_CN.GBK

# wine32-development-tools x11-apps:i386

# Use the latest version of winetricks 
RUN curl -SL 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks' -o /usr/local/bin/winetricks \
        && chmod +x /usr/local/bin/winetricks

ENV WINE_MONO_VERSION 4.6.2

# Get latest version of mono for wine 
RUN mkdir -p /usr/share/wine/mono && \
        curl -SL http://dl.winehq.org/wine/wine-mono/$WINE_MONO_VERSION/wine-mono-$WINE_MONO_VERSION.msi -o /usr/share/wine/mono/wine-mono-$WINE_MONO_VERSION.msi \
        && chmod +x /usr/share/wine/mono/wine-mono-$WINE_MONO_VERSION.msi

