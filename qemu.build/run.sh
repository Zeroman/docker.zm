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

    name=zeroman/qemu_build-$(basename $cur_dir)

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        XSOCK=/tmp/.X11-unix
        XAUTH=/tmp/.docker.xauth
        xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
        docker run -d --name $name --privileged --net=host $docker_opts $docker_bind \
            -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY \
            -v $cur_dir:/work \
            -w /work \
            zeroman/qemu_build $@
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

    name=zeroman.qemu_build-$(basename $cur_dir)

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        XSOCK=/tmp/.X11-unix
        XAUTH=/tmp/.docker.xauth
        xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
        docker run -it --rm --name $name --privileged --net=host $docker_opts $docker_bind \
            -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY \
            -v $cur_dir:/work \
            -w /work \
            zeroman/qemu_build $@
    else
        docker exec -it $name /bin/bash
    fi
}

update_virtio_win_iso()
{
    axel https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso
}

opt=$1
shift
case $opt in
    b|build)
        docker build -t zeroman/qemu_build .
        ;;
    bn|build_new)
        docker build -t zeroman/qemu_build --no-cache .
        ;;
    r|run)
        run_image /opt/qemu_build.sh $@
        ;;
    c|clean)
        docker rm zeroman/qemu_build
        docker rmi zeroman/qemu_build
        ;;
    upi|update_virtio_win_iso)
        update_virtio_win_iso
        ;;
    *)
        run_shell $opt $@
        ;;
esac

