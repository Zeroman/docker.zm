#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)

run_image()
{
    docker_opts=""
    docker_bind="-v $cur_dir/supervisord.conf:/etc/supervisord.conf"

    name=zeroman.supervisor-$(basename $cur_dir)

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name $docker_opts $docker_bind zeroman/supervisor 
    else
        docker start -it $name
    fi
}
 

opt=$1
shift
case $opt in
    b|build)
        docker build -t zeroman/supervisor .
        ;;
    bn|build_new)
        docker build -t zeroman/supervisor --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zeroman/supervisor
        docker rmi zeroman/supervisor
        ;;
    test)
        # rsync localhost::share 
        rsync rsync://localhost:/share 
        ;;
    sync)
        rsync -av rsync://$1:/share .
        ;;
    *)
        run_image $*
        ;;
esac

