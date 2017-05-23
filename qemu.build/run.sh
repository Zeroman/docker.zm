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

    name=qemu_build

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -d --name $name --privileged --net=host $docker_opts $docker_bind \
            -v $cur_dir:/work \
            -w /work \
            zeroman/qemu_build $@
    else
        docker exec -it $name $@
    fi
}

run_shell()
{
    docker_opts=""
    docker_bind="" 

    if [ -e $HOME/.bashrc ];then
        docker_bind+=" -v $HOME/.bashrc:/root/.bashrc:ro"
    fi

    name=qemu_build

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        XSOCK=/tmp/.X11-unix
        XAUTH=/tmp/.docker.xauth
        xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
        docker run -it --name $name --privileged --net=host $docker_opts $docker_bind \
            -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY \
            -v $cur_dir:/work \
            -w /work \
            zeroman/qemu_build $@
        # ldconfig # let /usr/local/lib into runtime library path
    else
        docker start -i $name 
    fi
}

update_virtio_win_iso()
{
    axel https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso
}

start_qemu() 
{
    cpuCores=1
    cpuThreads=1
    memorySize=1024
    qmpPort=4000
    spicePort=5000
    password=user
    disks=""

    for x in $@; do
        case $x in
            name=*)
                name=${x#name=}
                ;;
            cpuCores=*)
                cpuCore=${x#cpuCores=}
                ;;
            cpuThreads=*)
                cpuThreads=${x#cpuThreads=}
                ;;
            memorySize=*)
                memorySize=${x#memorySize=}
                ;;
            qmpPort=*)
                qmpPort=${x#qmpPort=}
                ;;
            spicePort=*)
                spicePort=${x#spicePort=}
                ;;
            password=*)
                password=${x#password=}
                ;;
            disk=*)
                disks+=" ${x#disk=}"
                ;;
            *)
                ;;
        esac
    done

    disk_args=""
    for disk in $disks; do
        if [ -e "$disk" ];then
            disk_args+=" -drive file=$disk,if=virtio,cache=writeback"
        fi
    done

    cmd="qemu-system-x86_64 "
    cmd+=$(cat qemu_cmdline.tmpl | sed \
        -e "s#\${name}#$name#g" \
        -e "s#\${cpuCores}#$cpuCores#g" \
        -e "s#\${cpuThreads}#$cpuThreads#g" \
        -e "s#\${memorySize}#$memorySize#g" \
        -e "s#\${qmpPort}#$qmpPort#g" \
        -e "s#\${spicePort}#$spicePort#g" \
        -e "s#\${password}#$password#g")
    cmd+=$disk_args
    echo $cmd
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
        # run_image $(start_qemu cpuCore=2 memorySize=3000 spicePort=4004 disk=./win7_sys.qcow2)
        # test -e /tmp/a.img || qemu-img create -f qcow2 /tmp/a.img 10G
        # test -e /tmp/b.img || qemu-img create -f qcow2 /tmp/b.img 10G
        # start_qemu cpuCore=2 memorySize=2000 disk=/tmp/a.img disk=/tmp/b.img
        start_qemu cpuCore=2 memorySize=3000 spicePort=4004 disk=./win7_sys.qcow2
        echo "spicy -h localhost -p 4004 -f"
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

