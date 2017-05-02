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

    if [ -e $cur_dir/supervisord.conf ];then
        docker_bind+=" -v $cur_dir/supervisord.conf:/etc/supervisord.conf"
    fi

    name=x11-$(basename $cur_dir)-$1

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -u developer \
            -v $cur_dir:/work \
            -w /work \
            zeroman/x11 $@
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
    docker run -it -d --name $name --net=host zeroman/x11 \
        distccd --daemon --user nobody --no-detach --allow 0.0.0.0/0

}
 

opt=$1
shift
case $opt in
    b|build)
        docker build -t zeroman/x11 --build-arg GID=$GROUPS --build-arg UID=$UID .
        ;;
    bn|build_new)
        docker build -t zeroman/x11 --no-cache --build-arg GID=$GROUPS --build-arg UID=$UID .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zeroman/x11
        docker rmi zeroman/x11
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

