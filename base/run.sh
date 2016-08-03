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
        docker_bind+=" -v $HOME/.bashrc:/home/developer/.bashrc:ro"
    fi

    name=zeroman.base-$(basename $cur_dir)

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -u developer \
            -v $cur_dir:/work \
            -w /work \
            zeroman/base $@
    else
        docker start -it $name
    fi
}
 

opt=$1
shift
case $opt in
    b|build)
        docker build -t zeroman/base --build-arg GID=$GROUPS --build-arg UID=$UID .
        ;;
    bn|build_new)
        docker build -t zeroman/base --no-cache --build-arg GID=$GROUPS --build-arg UID=$UID .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zeroman/base
        docker rmi zeroman/base
        ;;
    *)
        run_image $*
        ;;
esac

