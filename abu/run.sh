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

    name="abu_$(basename $cur_dir)"
    docker run -it --rm --name $name $docker_opts $docker_bind \
        -e UID=$UID -v $cur_dir:/work -w /work \
        -v $cur_dir/abu_home:/home/developer/abu \
        -p 4444:8888 \
        zeroman/abu $@
}

opt=$1
shift
case $opt in
    b|build)
        docker build -t zeroman/abu .
        ;;
    bn|build_new)
        docker build -t zeroman/abu --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    shell|sh|bash)
        run_image /bin/bash
        ;;
    t|test)
        test_image
        ;;
    c|clean)
        docker rm zeroman/abu
        docker rmi zeroman/abu
        ;;
    exec)
        docker exec -it abu_abu bash
        ;;
    *)
        run_image 
        ;;
esac

