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

    name=zm.base-$(basename $cur_dir)

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -v $cur_dir:/work \
            -w /work \
            zm.base $@
    else
        docker start -i zm.base
    fi
}
 

opt=$1
shift
case $opt in
    b|build)
        docker build -t zm.base .
        ;;
    bn|build_new)
        docker build -t zm.base --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zm.base
        docker rmi zm.base
        ;;
    *)
        run_image $*
        ;;
esac

