FROM zeroman/base

RUN wget http://dl.winehq.org/wine-builds/Release.key && apt-key add Release.key

RUN echo "deb http://dl.winehq.org/wine-builds/debian/ jessie main" > /etc/apt/sources.list.d/wine.list
RUN apt-get update 
RUN apt-get install -y --no-install-recommends -t jessie-backports \
        wine-devel winehq-devel winetricks ttf-mscorefonts-installer 

RUN apt-get install -y --no-install-recommends -t jessie-backports \
        libgl1-mesa-dri:i386

ADD lang.sh /etc/profile.d/
RUN echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && dpkg-reconfigure locales
USER developer

# RUN apt-get install -y # playonlinux

# RUN echo "zh_CN.GB2312 GB2312" > /etc/locale.gen && dpkg-reconfigure locales
# RUN echo "zh_CN.GB2312 GB2312" > /etc/locale.gen && dpkg-reconfigure locales
# echo '\nLANG="zh_CN.GB2312"\nLANGUAGE="zh_CN:zh"' > /etc/default/locale 
# RUN echo "zh_CN.GB2312 GB2312" > /etc/locale.gen && dpkg-reconfigure locales
# ENV LANG zh_CN.GB2312  
# ENV LANGUAGE zh_CN:zh  
# ENV LC_ALL zh_CN.GB2312 

# RUN apt-get install -y --no-install-recommends wine-development wine32-development wine32-development-preloader fonts-wine

# RUN apt-get install -y --no-install-recommends winetricks zenity

# wine32-development-tools x11-apps:i386

# Use the latest version of winetricks 
# RUN curl -SL 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks' -o /usr/local/bin/winetricks && chmod +x /usr/local/bin/winetricks

# ENV WINE_MONO_VERSION 4.6.2

# Get latest version of mono for wine 
# RUN mkdir -p /usr/share/wine/mono && curl -SL http://dl.winehq.org/wine/wine-mono/$WINE_MONO_VERSION/wine-mono-$WINE_MONO_VERSION.msi -o /usr/share/wine/mono/wine-mono-$WINE_MONO_VERSION.msi && chmod +x /usr/share/wine/mono/wine-mono-$WINE_MONO_VERSION.msi

# RUN echo "alias winegui='wine explorer /desktop=DockerDesktop,1024x768'" > ~/.bash_aliases 
# RUN echo "alias wi='LANG=zh_CN.GB2312 LC_ALL=zh_CN.GB2312 LANGUAGE=zh_CN:zh wine'" > ~/.bash_aliases 

# ENV LANG zh_CN.UTF-8  
# ENV LANGUAGE zh_CN:zh  
# ENV LC_ALL zh_CN.UTF-8 
# ENV WINEARCH win32

# cp wine_gecko-2.47-x86.msi /root/.cache/wine/
# wineboot -u

