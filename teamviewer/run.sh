#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)


# tv_home=/home/developer
tv_home=/root

run_image()
{
    docker_opts=""
    docker_bind="" 

    name=tv-$(basename $cur_dir)

    hostdev=false
    if $hostdev;then
        docker_opts+=" --privileged"
    fi

    if [ -d /dev/snd ];then
        # docker_opts+=" --group-add audio"
        docker_bind+=" --device /dev/snd"
        docker_bind+=" -v /run/dbus/:/run/dbus/"
        docker_bind+=" -v /dev/shm:/dev/shm"
    fi

    # mkdir -p $cur_dir/.tv
    docker_bind+=" -v $cur_dir/.tv:$tv_home/.tv"

    cmd="teamviewer"
    if [ "$#" != 0 ];then
        cmd=$@
    fi

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        # xhost +
        #XSOCK=/tmp/.X11-unix
        #XAUTH=/tmp/.docker.xauth
        #xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
        #docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            #-v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY \
            #-v $cur_dir:/work -w /work \
            #-e UID=$UID -v $cur_workdir/run.sh:/opt/tv/run.sh \
            #zeroman/tv $cmd
        mkdir -p home
        xhost +local:docker && docker run --rm -it --name $name \
            -e UID=$UID -u developer \
            -v $PWD/home/:/home/developer \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            zeroman/tv
    else
        docker start -i $name
    fi
}

tv_setup()
{
    export LANG=zh_CN.UTF-8  
    export LANGUAGE=zh_CN:zh  
    export LC_ALL=zh_CN.UTF-8 
    export WINEARCH=win32

    if [ ! ~/.tv ];then
        # tvtricks mfc42 #odbc32
        tvtricks vcrun6 vcrun6sp6
        tvtricks vcrun2005 vcrun2008 vcrun2010 vcrun2012 vcrun2013

        tvboot -u
    fi
    # tv explorer /desktop=DockerDesktop,1024x768
    tv explorer Z:\\work
    bash
}

tv_zhcn_font()
{
    # WINE=tv-development
    WINE=tv
    fonts_dir=$cur_dir/.tv/drive_c/windows/Fonts
    system_reg=$cur_dir/.tv/system.reg
    font_path=$cur_workdir/font/simsun.ttc
    font_reg=$cur_workdir/zhcn_font.reg
    if [ -d $fonts_dir -a -e $font_path -a -e $font_reg ];then
        # sudo cp -fv  $font_path $fonts_dir/
        sudo cp -fv $cur_workdir/font/*.ttf $cur_workdir/font/*.ttc $fonts_dir/
        # sed -i 's/LogPixels"=dword:00000060/LogPixels"=dword:00000070/g'    $system_reg
        # sed -i 's/MS Shell Dlg"="Tahoma/MS Shell Dlg"="SimSun/g'            $system_reg
        # sed -i 's/MS Shell Dlg 2"="Tahoma/MS Shell Dlg 2"="SimSun/g'        $system_reg
        sudo cp -fv $font_reg $cur_dir/.tv/drive_c/
        # run_image $WINE regedit /s c:\\zhcn_font.reg
    fi
}

start_teamview()
{
    XSOCK=/tmp/.X11-unix
    XAUTH=/tmp/.docker.xauth
    xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
    docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
        -e XMODIFIERS=@im=fcitx \
        -e GTK_IM_MODULE=fcitx \
        -e QT_IM_MODULE=fcitx \
        -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY \
        --name teamview hurricane/teamviewer bash
}

opt=$1
if [ -n "$opt" ];then
    shift
fi
case $opt in
    b|build)
        docker build -t zeroman/tv .
        ;;
    bn|build_new)
        docker build -t zeroman/tv --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zeroman/tv-$(basename $cur_dir)
        ;;
    ci|clean_image)
        docker rmi zeroman/tv
        ;;
    setup)
        tv_setup
        ;;
    ss)
        start_teamview
        ;;
    url)
        xdg-open https://www.teamviewer.com/cn/download/linux/
        ;;
    dl)
        wget https://download.teamviewer.com/download/linux/teamviewer_amd64.tar.xz
        ;;
    *)
        run_image $*
        ;;
esac


