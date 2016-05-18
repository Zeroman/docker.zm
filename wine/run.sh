#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)


run_image()
{
    docker_opts=""
    docker_bind="" 

    name=zm.wine-$(basename $cur_dir)

    docker_bind+="-v $PWD/.wine:/root/.wine" 

    if [ -e $HOME/.bashrc ];then
        docker_bind+=" -v $HOME/.bashrc:/root/.bashrc:ro"
    fi

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        # xhost +
        XSOCK=/tmp/.X11-unix
        XAUTH=/tmp/.docker.xauth
        xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY \
            -v $cur_dir:/work \
            -w /work \
            zm.wine $@
    else
        docker start -i $name
    fi
}


opt=$1
shift
case $opt in
    b|build)
        docker build -t zm.wine .
        ;;
    bn|build_new)
        docker build -t zm.wine --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    c|clean)
        docker rm zm.wine-$(basename $cur_dir)
        ;;
    ci|clean_image)
        docker rmi zm.wine
        ;;
    *)
        run_image $*
        ;;
esac


