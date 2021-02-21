#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)


# ncm_home=/home/user
ncm_home=/root

run_image()
{
    docker_opts=""
    docker_bind="" 

    name=ncm-$(basename $cur_dir)

    #docker_opts=" --network host"
    #docker_opts=" --privileged" #一定要加，否则起不来
    mkdir -p $cur_workdir/home

    cmd=""
    if [ -n "$1" ];then
        cmd=$@
    fi
    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        pkill ncm
        # xhost +
        XSOCK=/tmp/.X11-unix
        XAUTH=/tmp/.docker.xauth
        xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
        docker run -it --rm --name $name $docker_opts $docker_bind \
            -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY -e UID=$UID \
            -u user \
            -v $cur_dir/home:/home/user \
            -w /home/user \
            -e XMODIFIERS=@im=fcitx \
            -e GTK_IM_MODULE=xim \
            -e QT_IM_MODULE=xim \
            --device /dev/dri \
            --device /dev/snd \
            -e PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
            -v ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native \
            --group-add $(getent group audio | cut -d: -f3) \
            zeroman/ncm $cmd
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
        docker build -t zeroman/ncm .
        ;;
    bn|build_new)
        docker build -t zeroman/ncm --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zeroman/ncm-$(basename $cur_dir)
        ;;
    ci|clean_image)
        docker rmi zeroman/ncm
        ;;
    sh)
        run_image bash
        ;;
    *)
        run_image
        ;;
esac


