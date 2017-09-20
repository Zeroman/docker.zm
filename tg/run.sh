#!/bin/bash - 


run_telegram()
{
    docker run --rm -it --name telegram \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e DISPLAY=unix$DISPLAY \
        --device /dev/snd \
        -v /etc/localtime:/etc/localtime:ro \
        -v $PWD/.TelegramDesktop:/root/.local/share/TelegramDesktop/ \
        xorilog/telegram

}


case $1 in
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
