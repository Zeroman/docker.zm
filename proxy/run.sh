#!/usr/bin/env sh

proxy_env()
{
    case $1 in
        eg1)
            export http_proxy=http://proxynj.eg.com:80
            export https_proxy=https://proxynj.eg.com:80
            ;;
        eg2)
            export http_proxy=http://proxy2.eg.com:80
            export https_proxy=https://proxy2.eg.com:80
            ;;
        nj)
            export http_proxy=http://proxynj.zte.com.cn:80
            export https_proxy=https://proxynj.zte.com.cn:80
            ;;
        sz)
            export http_proxy=http://proxysz.zte.com.cn:80
            export https_proxy=https://proxysz.zte.com.cn:80
            ;;
        msn)
            export http_proxy=http://proxymsn.zte.com.cn:80
            export https_proxy=https://proxymsn.zte.com.cn:80
            ;;
        ssh)
            export ignore_addrs=45.79.91.227,45.79.91.226
            export gateway="yes"
            export ssh_proxy=127.0.0.1:7070
            ;;
        *)
            export global_proxy="yes"
            ;;
    esac
}

run_zm_proxy()
{
    proxy_env $1

    # -it --rm 
    # docker_opts='run -it --rm --name proxy --net=host --privileged'
    docker_opts='run -i -d --name proxy --net=host --privileged'
    test -z "$http_proxy" || docker_opts+=" -e http_proxy=$http_proxy"
    test -z "$https_proxy" || docker_opts+=" -e https_proxy=$https_proxy"
    test -z "$ssh_proxy" || docker_opts+=" -e ssh_proxy=$ssh_proxy"

    id=$(docker ps -a --filter name=proxy -q)
    if [ -n "$id" ];then
        docker stop proxy
        docker rm proxy
    fi
    docker $docker_opts zeroman/proxy
}


run_local_proxy()
{ 
    if [ $UID != 0 ];then
        echo "Please use sudo or root."
        exit 1
    fi
    proxy_env $1
    sh ./redsocks 
}

run_shadowsocks()
{
    name=ss_proxy
    SSPASSWORD=toor
    EPMETHOD=rc4-md5
    # EPMETHOD=aes-256-cfb

    # docker_opts='run -i -d --name $name --net=host --privileged'
    # docker_opts="run -it --rm --name $name -p 1984:1984"
    docker_opts="run -i -d --name $name -p 1984:1984"
    id=$(docker ps -a --filter name=$name -q)
    if [ -n "$id" ];then
        docker stop $name
        docker rm $name
    fi
    # ss_opts="ssserver -s 0.0.0.0  -p 1984 -k $SSPASSWORD -m $EPMETHOD --fast-open -vv"
    ss_opts="ssserver -s 0.0.0.0  -p 1984 -k $SSPASSWORD -m $EPMETHOD --fast-open"
    docker $docker_opts zeroman/proxy $ss_opts
}

case $1 in
    fw)
        shift
        echo $1 | sudo tee /proc/sys/net/ipv4/ip_forward
        ;;
    b|build)
        docker build -t zeroman/proxy .
        ;;
    bn|build_new)
        docker build -t zeroman/proxy --no-cache .
        ;;
    r|run)
        shift
        run_zm_proxy $@
        ;;
    c|clean)
        docker rm proxy
        docker rmi zeroman/proxy 
        ;;
    test)
        shift
        run_local_proxy $@
        ;;
    ss|shadowsocks)
        run_shadowsocks
        ;;
    *)
        run_zm_proxy $@
        ;;
esac
