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
        docker_bind+=" -v $HOME/.bashrc:/root/.bashrc:ro"
    fi

    name=zeroman/qemu-$(basename $cur_dir)

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        XSOCK=/tmp/.X11-unix
        XAUTH=/tmp/.docker.xauth
        xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
        docker run -d --name $name --privileged --net=host $docker_opts $docker_bind \
            -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY \
            -v $cur_dir:/work \
            -w /work \
            zeroman/qemu $@
    else
        docker exec -it $name /bin/bash
    fi
}

run_shell()
{
    docker_opts=""
    docker_bind="" 

    if [ -e $HOME/.bashrc ];then
        docker_bind+=" -v $HOME/.bashrc:/root/.bashrc:ro"
    fi

    name=zeroman.qemu-$(basename $cur_dir)

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name --privileged --net=host $docker_opts $docker_bind \
            -v $cur_dir:/work \
            -w /work \
            zeroman/qemu /bin/bash
    else
        docker exec -it $name /bin/bash
    fi
}

opt=$1
shift
case $opt in
    b|build)
        docker build -t zeroman/qemu .
        ;;
    bn|build_new)
        docker build -t zeroman/qemu --no-cache .
        ;;
    r|run)
        run_image /opt/qemu.sh $@
        ;;
    c|clean)
        docker rm zeroman/qemu
        docker rmi zeroman/qemu
        ;;
    dl)
        wget https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-latest.exe -O spice-guest-tools-latest.exe
        ;;
    *)
        run_shell $opt $@
        ;;
esac

