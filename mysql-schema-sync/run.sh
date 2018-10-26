#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)

run_image()
{
    docker_opts=""
    docker_bind="" 

    name=mysql-schema-sync

    if [ -e $cur_dir/config.json ];then
        docker_bind+=" -v $cur_dir/config.json:/root/config.json:ro"
    fi

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -v $cur_dir:/work -w /root zeroman/mysql-schema-sync $@
    else
        docker start -it $name
    fi
}

opt=$1
shift
case $opt in
    b|build)
        docker build -t zeroman/mysql-schema-sync .
        ;;
    bn|build_new)
        docker build -t zeroman/mysql-schema-sync --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zeroman/mysql-schema-sync
        docker rmi zeroman/mysql-schema-sync
        ;;
    sh)
        run_image sh
        ;;
    sync)
        run_image mysql-schema-sync -sync
        ;;
    *)
        run_image 
        ;;
esac

