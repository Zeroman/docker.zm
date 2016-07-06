#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)

container_name=zm.sshd-$(basename $cur_dir)

run_image()
{
    docker_opts=""
    docker_bind="" 

    name=$container_name

    id=$(docker ps -a --filter name=$name -q)
    if [ -z "$id" ];then
        docker run -d -p 2222:22 --name $name $docker_opts $docker_bind \
            zm.sshd $@
    else
        docker start -i zm.sshd
    fi
    docker port $name 
}

test_sshd()
{
    if [ ! -e test_key.pub ];then
        # ssh-keygen -t rsa -f test_key
        ssh-keygen -t rsa -N 11111 -f test_key
        ssh-copy-id -p 2222 -i test_key.pub root@localhost
    fi
    ssh -p 2222 -i test_key root@localhost 
}
 

opt=$1
shift
case $opt in
    b|build)
        docker build -t zm.sshd .
        ;;
    bn|build_new)
        docker build -t zm.sshd --no-cache .
        ;;
    r|run)
        run_image $@
        ;;
    t|test)
        test_sshd
        ;;
    s|shell)
        docker exec -it $container_name /bin/bash
        ;;
    c|clean)
        docker stop $container_name
        docker rm  $container_name
        rm -fv test_key*
        # docker rmi zm.sshd
        ;;
    *)
        run_image $*
        ;;
esac

