#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)


# wine_home=/home/developer
wine_home=/root

run_image()
{
    docker_opts=""
    docker_bind="" 

    name=wine-$(basename $cur_dir)

    hostdev=true
    if $hostdev;then
        docker_opts+=" --privileged"
    fi

    if [ -e $HOME/.bashrc ];then
        docker_bind+=" -v $HOME/.bashrc:$wine_home/.bashrc:ro"
    fi

    if [ -d /dev/snd ];then
        # docker_opts+=" --group-add audio"
        docker_bind+=" --device /dev/snd"
        docker_bind+=" -v /run/dbus/:/run/dbus/"
        docker_bind+=" -v /dev/shm:/dev/shm"
    fi

    if [ ! -d $cur_workdir/cache ];then
        mkdir -p $cur_workdir/cache/wine 
        mkdir -p $cur_workdir/cache/winetricks
    fi
    docker_bind+=" -v $cur_workdir/cache/wine:$wine_home/.cache/wine"

    # mkdir -p $cur_dir/.wine
    docker_bind+=" -v $cur_dir/.wine:$wine_home/.wine"

    cmd="/opt/wine/run.sh setup"
    if [ "$#" != 0 ];then
        cmd=$@
    fi

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        # xhost +
        XSOCK=/tmp/.X11-unix
        XAUTH=/tmp/.docker.xauth
        xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -e XMODIFIERS=@im=fcitx \
            -e GTK_IM_MODULE=fcitx \
            -e QT_IM_MODULE=fcitx \
            -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY \
            -v $cur_dir:/work -w /work \
            -e UID=$UID -v $cur_workdir/run.sh:/opt/wine/run.sh \
            zeroman/wine $cmd
    else
        docker start -i $name
    fi
}

wine_setup()
{
    #export LANG=zh_CN.UTF-8  
    #export LANGUAGE=zh_CN:zh  
    #export LC_ALL=zh_CN.UTF-8 
    export LANG=zh_CN.GB2312
    export LANGUAGE=zh_CN:zh  
    export LC_ALL=zh_CN.GB2312

    export WINEARCH=win32

    if [ ! ~/.wine ];then
        # winetricks mfc42 #odbc32
        winetricks vcrun6 vcrun6sp6
        winetricks vcrun2005 vcrun2008 vcrun2010 vcrun2012 vcrun2013

        wineboot -u
    fi
    #wine explorer /desktop=DockerDesktop,1024x768
    wine explorer Z:\\work
    bash
}

wine_zhcn_font()
{
    # WINE=wine-development
    WINE=wine
    fonts_dir=$cur_dir/.wine/drive_c/windows/Fonts
    system_reg=$cur_dir/.wine/system.reg
    font_path=$cur_workdir/font/simsun.ttc
    font_reg=$cur_workdir/zhcn_font.reg
    if [ -d $fonts_dir -a -e $font_path -a -e $font_reg ];then
        # sudo cp -fv  $font_path $fonts_dir/
        sudo cp -fv $cur_workdir/font/*.ttf $cur_workdir/font/*.ttc $fonts_dir/
        # sed -i 's/LogPixels"=dword:00000060/LogPixels"=dword:00000070/g'    $system_reg
        # sed -i 's/MS Shell Dlg"="Tahoma/MS Shell Dlg"="SimSun/g'            $system_reg
        # sed -i 's/MS Shell Dlg 2"="Tahoma/MS Shell Dlg 2"="SimSun/g'        $system_reg
        sudo cp -fv $font_reg $cur_dir/.wine/drive_c/
        # run_image $WINE regedit /s c:\\zhcn_font.reg
    fi
}


opt=$1
if [ -n "$opt" ];then
    shift
fi
case $opt in
    b|build)
        docker build -t zeroman/wine .
        ;;
    bn|build_new)
        docker build -t zeroman/wine --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zeroman/wine-$(basename $cur_dir)
        ;;
    ci|clean_image)
        docker rmi zeroman/wine
        ;;
    cn|chinese_font)
        wine_zhcn_font
        ;;
    setup)
        wine_setup
        ;;
    *)
        run_image $*
        ;;
esac


