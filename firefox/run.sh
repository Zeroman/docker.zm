#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)


# firefox_home=/home/developer
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

    if [ -e $HOME/.bashrc ];then
        docker_bind+=" -v $HOME/.bashrc:$firefox_home/.bashrc:ro"
    fi

    if [ -d /dev/snd ];then
        # docker_opts+=" --group-add audio"
        docker_bind+=" --device /dev/snd"
        docker_bind+=" -v /run/dbus/:/run/dbus/"
        docker_bind+=" -v /dev/shm:/dev/shm"
    fi

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        # xhost +
        XSOCK=/tmp/.X11-unix
        XAUTH=/tmp/.docker.xauth
        xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY \
            -e UID=$UID \
            zeroman/firefox bash
    else
        docker start -i $name
    fi
}

opt=$1
shift
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
    *)
        run_image $*
        ;;
esac


