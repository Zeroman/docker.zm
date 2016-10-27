#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)


run_image()
{
    docker_opts=""
    docker_bind="" 

    name=zeroman-texlive-$(basename $cur_dir)

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -v $cur_dir:/work \
            -w /work \
            zeroman/texlive $*
    else
        docker start -i zeroman/texlive
    fi
}


opt=$1
shift
case $opt in
    b|build)
        docker build -t zeroman/texlive .
        ;;
    bn|build_new)
        docker build -t zeroman/texlive --no-cache .
        ;;
    r|run)
        run_image $*
        ;;
    c|clean)
        docker rm zeroman/texlive
        docker rmi zeroman/texlive
        ;;
    *)
        run_image $*
        ;;
esac


