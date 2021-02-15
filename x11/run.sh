#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)

run_image()
{
    docker_opts=""
    docker_bind="" 

    if [ -e $HOME/.bashrc ];then
        docker_bind+=" -v $HOME/.bashrc:/home/user/.bashrc:ro"
    fi

    if [ -e $cur_dir/supervisord.conf ];then
        docker_bind+=" -v $cur_dir/supervisord.conf:/etc/supervisord.conf"
    fi

    name=x11-$(basename $cur_dir)-$1

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        XSOCK=/tmp/.X11-unix
        XAUTH=/tmp/.docker.xauth
        xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -e XMODIFIERS=@im=fcitx \
            -e GTK_IM_MODULE=xim \
            -e QT_IM_MODULE=xim \
            -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY \
            --cap-add=SYS_ADMIN \
            --device /dev/snd \
            -e PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
            -v ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native \
            --group-add $(getent group audio | cut -d: -f3) \
            --device /dev/dri \
            -u user \
            -v $cur_dir:/work \
            -w /work \
            zeroman/x11 $@
    else
        docker start -it $name
    fi
}

opt=$1
if [ -n "$opt" ];then
    shift
fi
case $opt in
    b|build)
        docker build -t zeroman/x11 --build-arg GID=$GROUPS --build-arg UID=$UID .
        ;;
    bn|build_new)
        docker build -t zeroman/x11 --no-cache --build-arg GID=$GROUPS --build-arg UID=$UID .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zeroman/x11
        docker rmi zeroman/x11
        ;;
    sd|stop_distcc)
        name=distccd
        docker kill $name
        docker rm $name
        ;;
    *)
        run_image bash
        ;;
esac

