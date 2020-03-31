#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)


# bdpan_home=/home/developer
bdpan_home=/root

run_image()
{
    docker_opts=""
    docker_bind="" 

    name=bdpan-$(basename $cur_dir)

    #docker_opts=" --network host"
    mkdir -p $cur_workdir/home

    cmd=bash
    if [ -n "$1" ];then
        cmd=$@
    fi
    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        pkill bdpan
        # xhost +
        XSOCK=/tmp/.X11-unix
        XAUTH=/tmp/.docker.xauth
        xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
        docker run -it --rm --name $name $docker_opts $docker_bind \
            -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY -e UID=$UID \
            -u developer \
            -v $cur_dir/home:/home/developer \
            -w //home/developer \
            -e XMODIFIERS=@im=fcitx \
            -e GTK_IM_MODULE=xim \
            -e QT_IM_MODULE=xim \
            zeroman/bdpan $cmd
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
        docker build -t zeroman/bdpan .
        ;;
    bn|build_new)
        docker build -t zeroman/bdpan --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zeroman/bdpan-$(basename $cur_dir)
        ;;
    ci|clean_image)
        docker rmi zeroman/bdpan
        ;;
    sh)
        run_image bash
        ;;
    *)
        run_image
        ;;
esac


