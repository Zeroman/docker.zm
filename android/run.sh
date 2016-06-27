#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)


run_image()
{
    docker_opts=""
    docker_bind="" 
    contain_params=""

    hostdev=true

    if $hostdev;then
        docker_opts+=" --privileged"
    fi

    if [ -e $HOME/.bashrc ];then
        docker_bind+=" -v $HOME/.bashrc:/root/.bashrc:ro"
    fi

    for rule in "*.rules"
    do
        if [ -e $rule ];then
            docker_bind+=" -v $PWD/$rule:/etc/udev/rules.d/$rule:ro"
        fi
    done

    name=zm.android-$(basename $cur_dir)

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -it --rm --name $name --net=host $docker_opts $docker_bind \
            -v $cur_dir:/work \
            -e UID=$UID \
            -w /work \
            zm.android $contain_params
    else
        # docker start -i $name
        docker exec -it $name bash
    fi
}

test_image()
{
    echo "test now" 
}


opt=$1
shift
case $opt in
    b|build)
        docker build -t zm.android .
        ;;
    bn|build_new)
        docker build -t zm.android --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    t|test)
        test_image
        ;;
    c|clean)
        docker rm zm.android
        docker rmi zm.android
        ;;
    *)
        run_image $*
        ;;
esac

