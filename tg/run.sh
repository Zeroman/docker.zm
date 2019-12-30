#!/bin/bash - 


run_telegram()
{
    #--device /dev/snd \
    #-v /tmp/.X11-unix:/tmp/.X11-unix \
    #-e DISPLAY=unix$DISPLAY \

    XSOCK=/tmp/.X11-unix
    XAUTH=/tmp/.docker.xauth
    xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
    docker run --rm -it --name telegram \
        -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY \
        -e UID=$UID \
        -e XMODIFIERS=@im=fcitx \
        -e GTK_IM_MODULE=xim \
        -e QT_IM_MODULE=xim \
        -e LANG=zh_CN.UTF-8  \
        -e LANGUAGE=zh_CN:zh  \
        -e LC_ALL=zh_CN.UTF-8 \
        -v /etc/localtime:/etc/localtime:ro \
        -v $PWD/.TelegramDesktop:/root/.local/share/TelegramDesktop/ \
        --network host \
        zeroman/tg

        # xorilog/telegram
}

case $1 in
    b|build)
        docker build -t zeroman/tg --build-arg GID=$GROUPS --build-arg UID=$UID .
        ;;
    bn|build_new)
        docker build -t zeroman/tg --no-cache --build-arg GID=$GROUPS --build-arg UID=$UID .
        ;;
    c|clean)
        docker stop telegram
        docker rm telegram
        ;;
    *)
        #xhost +
        run_telegram
        #xhost -
        ;;
esac
