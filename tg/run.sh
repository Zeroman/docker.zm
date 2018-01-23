#!/bin/bash - 


run_telegram()
{
    docker run --rm -it --name telegram \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e DISPLAY=unix$DISPLAY \
        --device /dev/snd \
        -v /etc/localtime:/etc/localtime:ro \
        -v $PWD/.TelegramDesktop:/root/.local/share/TelegramDesktop/ \
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
        xhost +
        run_telegram
        xhost -
        ;;
esac
