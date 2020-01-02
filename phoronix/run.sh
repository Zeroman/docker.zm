#!/bin/bash

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)


# phoronix_home=/home/developer
phoronix_home=/root

run_image()
{
    docker_opts=""
    docker_bind="" 

    name=phoronix-$(basename $cur_dir)

    #docker_opts+=" --net host"

    if [ -d /dev/snd ];then
        #docker_opts+=" --group-add audio"
        #docker_bind+=" --device /dev/snd"
        #docker_bind+=" -v /run/dbus/:/run/dbus/"
        #docker_bind+=" -v /dev/shm:/dev/shm"
        true
    fi

    mkdir -p phoronix/lib
    mkdir -p phoronix/cache
    docker_bind+=" -v $PWD/phoronix/lib:/var/lib/phoronix-test-suite"
    docker_bind+=" -v $PWD/phoronix/cache:/var/cache/phoronix-test-suite"

    cmd="phoronix-test-suite"
    cmd=""
    if [ "$#" != 0 ];then
        cmd=$@
    fi

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name $docker_opts $docker_bind \
            zeroman/phoronix $cmd
    else
        docker start -i $name
    fi
}

phoronix_setup()
{
    export LANG=zh_CN.UTF-8  
    export LANGUAGE=zh_CN:zh  
    export LC_ALL=zh_CN.UTF-8 
    export WINEARCH=win32

    if [ ! ~/.phoronix ];then
        # phoronixtricks mfc42 #odbc32
        phoronixtricks vcrun6 vcrun6sp6
        phoronixtricks vcrun2005 vcrun2008 vcrun2010 vcrun2012 vcrun2013

        phoronixboot -u
    fi
    # phoronix explorer /desktop=DockerDesktop,1024x768
    phoronix explorer Z:\\work
    bash
}

phoronix_zhcn_font()
{
    # WINE=phoronix-development
    WINE=phoronix
    fonts_dir=$cur_dir/.phoronix/drive_c/windows/Fonts
    system_reg=$cur_dir/.phoronix/system.reg
    font_path=$cur_workdir/font/simsun.ttc
    font_reg=$cur_workdir/zhcn_font.reg
    if [ -d $fonts_dir -a -e $font_path -a -e $font_reg ];then
        # sudo cp -fv  $font_path $fonts_dir/
        sudo cp -fv $cur_workdir/font/*.ttf $cur_workdir/font/*.ttc $fonts_dir/
        # sed -i 's/LogPixels"=dword:00000060/LogPixels"=dword:00000070/g'    $system_reg
        # sed -i 's/MS Shell Dlg"="Tahoma/MS Shell Dlg"="SimSun/g'            $system_reg
        # sed -i 's/MS Shell Dlg 2"="Tahoma/MS Shell Dlg 2"="SimSun/g'        $system_reg
        sudo cp -fv $font_reg $cur_dir/.phoronix/drive_c/
        # run_image $WINE regedit /s c:\\zhcn_font.reg
    fi
}

start_phoronix()
{
    XSOCK=/tmp/.X11-unix
    XAUTH=/tmp/.docker.xauth
    xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
    docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
        -e XMODIFIERS=@im=fcitx \
        -e GTK_IM_MODULE=fcitx \
        -e QT_IM_MODULE=fcitx \
        -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY \
        --name phoronix hurricane/phoronix bash
}

run_tg_dd()
{
    xhost +local:docker && docker run --rm -it --net host \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v $PWD/phoronix/config/:/opt/phoronix/config/ \
        -v $PWD/phoronix/profile/:/opt/phoronix/profile/ \
        -e 'DISPLAY=:0' albertalvarezbruned/phoronix:14
}

opt=$1
if [ -n "$opt" ];then
    shift
fi
case $opt in
    b|build)
        docker build -t zeroman/phoronix .
        ;;
    bn|build_new)
        docker build -t zeroman/phoronix --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zeroman/phoronix-$(basename $cur_dir)
        ;;
    ci|clean_image)
        docker rmi zeroman/phoronix
        ;;
    setup)
        phoronix_setup
        ;;
    ss)
        start_phoronix
        ;;
    url)
        xdg-open https://www.phoronix.com/cn/download/linux/
        ;;
    dl)
        ;;
    scp)
        scp run.sh Dockerfile .dockerignore quant:/work/phoronix/
        ;;
    sh|bash)
        docker exec -it phoronix-phoronix bash
        ;;
    *)
        run_image $*
        #run_tg_dd
        ;;
esac


