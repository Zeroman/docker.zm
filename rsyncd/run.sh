#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)

run_image()
{
    docker_opts=""
    docker_bind="" 

    #docker_opts="--net=host "
    name=zeroman.rsyncd-$(basename $cur_dir)

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name $docker_opts $docker_bind \
            -v $cur_dir:/share \
            -p 873:873
            zeroman/rsyncd 
    else
        docker start -it $name
    fi
}
 

opt=$1
if [ -n "$opt" ];then
    shift
fi
case $opt in
    b|build)
        docker build -t zeroman/rsyncd .
        ;;
    bn|build_new)
        docker build -t zeroman/rsyncd --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zeroman/rsyncd
        docker rmi zeroman/rsyncd
        ;;
    test)
        # rsync localhost::share 
        #rsync rsync://localhost:/share 
        rsync rsync://test1@localhost:/share 
        ;;
    sync)
        rsync -avP --delete rsync://$1:/share .
        #rsync -avP rsync://$1:/share .
        ;;
    *)
        run_image $*
        ;;
esac

