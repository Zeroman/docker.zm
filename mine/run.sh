#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)

run_image()
{
    docker_opts="--device=/dev/kfd --device=/dev/dri --group-add video "
    docker_bind="" 

    if [ -e $HOME/.bashrc ];then
        docker_bind+=" -v $HOME/.bashrc:/home/developer/.bashrc:ro"
    fi

    if [ -e $cur_dir/supervisord.conf ];then
        docker_bind+=" -v $cur_dir/supervisord.conf:/etc/supervisord.conf"
    fi

    name=ttc-$(basename $cur_dir)-$1

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -v $cur_dir:/work \
            -w /work \
            zeroman/ttc $@
    else
        docker start -it $name
    fi
}

opt=$1
shift
case $opt in
    b|build)
        docker build -t zeroman/ttc --build-arg GID=$GROUPS --build-arg UID=$UID .
        ;;
    bn|build_new)
        docker build -t zeroman/ttc --no-cache --build-arg GID=$GROUPS --build-arg UID=$UID .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zeroman/ttc
        docker rmi zeroman/ttc
        ;;
    sd|stop_distcc)
        name=distccd
        docker kill $name
        docker rm $name
        ;;
    *)
        run_image 
        ;;
esac

