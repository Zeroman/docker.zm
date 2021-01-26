#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)


run_image()
{
    docker_opts=""
    docker_bind="" 

    name=python-$(basename $cur_dir)

    #docker_opts=" --network host"

    cmd=bash
    if [ -n "$1" ];then
        cmd=$@
    fi
    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        # xhost +
        XSOCK=/tmp/.X11-unix
        XAUTH=/tmp/.docker.xauth
        xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
        docker run -it --rm --name $name $docker_opts $docker_bind \
            -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY -e UID=$UID \
            -u user -v $cur_dir:/work -w /work \
            -e XMODIFIERS=@im=fcitx \
            -e GTK_IM_MODULE=xim \
            -e QT_IM_MODULE=xim \
            zeroman/python $cmd
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
        docker build -t zeroman/python .
        ;;
    bn|build_new)
        docker build -t zeroman/python --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    shell)
        run_image /bin/bash
        ;;
    c|clean)
        docker rm zeroman/python
        docker rmi zeroman/python
        ;;
    *)
        #docker run -it --rm zeroman/python $@
        run_image $@
        ;;
esac

