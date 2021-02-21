#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)


# firefox_home=/home/user
firefox_home=/root

run_image()
{
    docker_opts=""
    docker_bind="" 

    name=firefox-$(basename $cur_dir)

    hostdev=false
    if $hostdev;then
        docker_opts+=" --privileged"
    fi

    #--device /dev/snd 
    docker_opts=" --network host"

    if [ -d /dev/snd ];then
        docker_opts+=" --group-add audio"
        docker_bind+=" --device /dev/snd"
        docker_bind+=" -v /run/dbus/:/run/dbus/"
        docker_bind+=" -v /dev/shm:/dev/shm"
    fi

    cmd=firefox
    if [ -n "$1" ];then
        cmd=$@
    fi
    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        pkill -f /usr/lib/firefox/firefox
        # xhost +
        XSOCK=/tmp/.X11-unix
        XAUTH=/tmp/.docker.xauth
        xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
        docker run -it --rm --name $name $docker_opts $docker_bind \
            -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY -e UID=$UID \
            -u user \
            -v $cur_dir:/home/user \
            -w /work \
            -e XMODIFIERS=@im=fcitx \
            -e GTK_IM_MODULE=xim \
            -e QT_IM_MODULE=xim \
            --cap-add=SYS_ADMIN \
            --device /dev/snd \
            -e PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
            -v ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native \
            --group-add $(getent group audio | cut -d: -f3) \
            --device /dev/dri \
            zeroman/firefox $cmd

    else
        docker start -i $name
    fi
}

opt=''
if [ -n "$1" ];then
    opt=$1
    shift
fi
case $opt in
    b|build)
        docker build -t zeroman/firefox .
        ;;
    bn|build_new)
        docker build -t zeroman/firefox --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zeroman/firefox-$(basename $cur_dir)
        ;;
    ci|clean_image)
        docker rmi zeroman/firefox
        ;;
    sh)
        run_image bash
        ;;
    *)
        run_image
        ;;
esac


