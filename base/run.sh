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

    dirname=$(echo "$(basename $cur_dir)" | awk '{print gensub(/[^!-~]/,"","g",$0)}')
    name=base-$dirname
    if [ -z "$dirname" ];then
        name=base-$RANDOM
    fi

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -u user \
            -v $cur_dir:/work \
            -w /work \
            zeroman/base $@
    else
        docker start -it $name
    fi
}

start_distcc_server()
{
    name=distcc_server
    id=$(docker ps -a --filter name=$name -q)
    if [ -n "$id" ];then
        docker kill $name
        docker rm $name
    fi
    docker run -it -d --name $name --net=host zeroman/base \
        distccd --daemon --user nobody --no-detach --allow 0.0.0.0/0

}
 

opt=$1
if [ -n "$opt" ];then
    shift
fi
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
    distcc)
        start_distcc_server
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

