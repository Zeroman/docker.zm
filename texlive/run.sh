#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)


run_image()
{
    docker_opts=""
    docker_bind="" 

    name=zm.texlive-$(basename $cur_dir)

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -v $cur_dir:/work \
            -w /work \
            zm.texlive $*
    else
        docker start -i zm.texlive
    fi
}


opt=$1
shift
case $opt in
    b|build)
        docker build -t zm.texlive .
        ;;
    bn|build_new)
        docker build -t zm.texlive --no-cache .
        ;;
    r|run)
        run_image $*
        ;;
    c|clean)
        docker rm zm.texlive
        docker rmi zm.texlive
        ;;
    *)
        run_image $*
        ;;
esac


