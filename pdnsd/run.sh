#!/usr/bin/env sh

run_docker_dnsd()
{
    docker_opts=''

    docker_opts+=' run -it --rm --name dnsd --net=host'
    docker_opts+=' -e SERVERIP=10.72.1.7'

    id=$(docker ps -a --filter name=dnsd -q)
    if [ -n "$id" ];then
        docker stop dnsd
        docker rm dnsd
    fi
    # docker $docker_opts dnsd 10.72.24.190:yzm.znv 10.72.68.105:server.znv
    docker $docker_opts dnsd 10.72.24.190:yzm.znv 10.72.8.76:yyw.com
}


case $1 in
    b|build)
        docker build -t dnsd .
        ;;
    r|run)
        shift
        run_docker_dnsd $@
        ;;
    c|clean)
        docker rm dnsd
        docker rmi docker.dnsd 
        ;;
    *)
        run_docker_dnsd $@
        ;;
esac
