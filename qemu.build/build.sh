#!/bin/bash -e


build_virgl() 
{
    test -e /usr/lib/libvirglrenderer.so && return

    cd $BUILD_ROOT
    test -d virglrenderer || git clone  git://cgit.freedesktop.org/virglrenderer.git
    test -d spice-protocol || git clone
    cd virglrenderer
    test -e configure || test -e autogen.sh && ./autogen.sh --prefix=/usr
    test -e Makefile || ./configure --prefix=/usr
    $MAKE 
    make install
}

build_epoxy()
{
    test -e /usr/local/lib/libepoxy.so && return

    cd $BUILD_ROOT
    if [ ! -d libepoxy ];then
        git clone https://github.com/anholt/libepoxy.git
        git checkout 1.4.2 -b 1.4.2
    fi
    cd libepoxy
    test -e configure || test -e autogen.sh && ./autogen.sh --prefix=/usr
    # ./configure --prefix=/usr
    $MAKE
    make install
}

build_celt()
{
    test -e /usr/lib/libcelt051.so && return

    cd $BUILD_ROOT
    if [ ! -d celt-0.5.1.3 ];then
        wget http://downloads.us.xiph.org/releases/celt/celt-0.5.1.3.tar.gz
        tar xvzf celt-0.5.1.3.tar.gz
    fi
    cd celt-0.5.1.3/
    test -e Makefile || ./configure --prefix=/usr
    $MAKE
    make install
}

build_lz4()
{
    test -e /usr/lib/liblz4.so && return

    cd $BUILD_ROOT
    test -d lz4 || git clone https://github.com/lz4/lz4.git
    cd lz4
    test -e configure || test -e autogen.sh && ./autogen.sh
    test -e Makefile || ./configure --prefix=/usr
    $MAKE PREFIX=/usr install
}

build_spice_protocol()
{
    test -e /usr/share/pkgconfig/spice-protocol.pc && return

    cd $BUILD_ROOT
    test -d spice-protocol || git clone git://cgit.freedesktop.org/spice/spice-protocol
    cd spice-protocol
    test -e configure || ./autogen.sh
    test -e Makefile || CFLAGS=-Wno-missing-field-initializers ./configure --prefix=/usr
    $MAKE
    make install
}

build_spice()
{
    test -e /usr/lib/libspice-server.so && return

    cd $BUILD_ROOT
    test -d spice || git clone git://cgit.freedesktop.org/spice/spice
    cd spice
    test -e configure || ./autogen.sh
    test -e Makefile || CFLAGS=-Wno-missing-field-initializers ./configure --prefix=/usr
    $MAKE
    make install
}

build_qemu()
{
    cd $BUILD_ROOT
    test -d qemu || git clone git://git.qemu.org/qemu.git
    cd qemu
    test -e configure || ./autogen.sh
    ./configure --prefix=/usr --target-list=x86_64-softmmu --enable-spice
    $MAKE
    make install
}

update_git()
{
    cd $BUILD_ROOT
    for dir in $(ls -d */)
    do
        if [ -d $dir/.git ];then
            cd $dir
            git fetch
            git pull --recurse-submodules=yes
            cd -
        fi
    done
    
}

export BUILD_ROOT=$PWD/build
export MAKE='make -j9'
mkdir -p $BUILD_ROOT
# export INST_ROOT="/opt/spice"; mkdir -p $INST_ROOT
# export PKG_CONFIG_PATH=$INST_ROOT/lib/pkgconfig:$PKG_CONFIG_PATH

# update_git

build_lz4
build_epoxy
build_celt
build_spice_protocol
build_spice
build_virgl
build_qemu



