#!/bin/bash - 


run_qt()
{
    docker_opts=""
    docker_bind="" 

    #--device /dev/snd \
    #-v /tmp/.X11-unix:/tmp/.X11-unix \
    #-e DISPLAY=unix$DISPLAY \
        #-v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY \

    XSOCK=/tmp/.X11-unix
    XAUTH=/tmp/.docker.xauth
    xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
    docker run --rm -it --name qt $docker_opts $docker_bind \
        -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY \
        -e XMODIFIERS=@im=fcitx \
        -e GTK_IM_MODULE=xim \
        -e QT_IM_MODULE=xim \
        -e XIM_PROGRAM=xim \
        -e XIM=xim \
        -u user \
        -e UID=$UID \
        -e LANG=zh_CN.UTF-8  \
        -e LANGUAGE=zh_CN:zh  \
        -e LC_ALL=zh_CN.UTF-8 \
        -v /etc/localtime:/etc/localtime:ro \
        --privileged zeroman/qt

        # xorilog/qt
}

case $1 in
    b|build)
        docker build -t zeroman/qt --build-arg GID=$GROUPS --build-arg UID=$UID .
        ;;
    bn|build_new)
        docker build -t zeroman/qt --no-cache --build-arg GID=$GROUPS --build-arg UID=$UID .
        ;;
    c|clean)
        docker stop qt
        docker rm qt
        ;;
    *)
        #xhost +
        run_qt
        #xhost -
        ;;
esac
