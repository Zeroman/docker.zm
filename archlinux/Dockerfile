FROM scratch 

ADD archlinux.tar.gz /

ADD mirrorlist /etc/pacman.d/mirrorlist

RUN test -e /etc/pacman.d/gnupg/trustdb.gpg || { pacman-key --init; pacman-key --populate archlinux; }

RUN pacman -Suy --noconfirm;pacman -S --needed --noconfirm file findutils gawk gettext \
        grep gzip pacman sed util-linux which net-tools \
        libx11 gcc-libs zlib bzip2 ncurses ttf-droid

CMD /bin/bash
