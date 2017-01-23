#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)

socks_inport=7070

proxy_env()
{
    export docker_iface=docker0

    case $1 in
        eg1)
            export http_proxy=http://proxy.eg.com:80
            export https_proxy=https://proxy.eg.com:80
            ;;
        eg2)
            export http_proxy=http://proxy2.eg.com:80
            export https_proxy=https://proxy2.eg.com:80
            ;;
        socks)
            export gateway="yes"
            # export ignore_addrs="45.79.91.227:22,45.79.91.226:22"
            export socks_proxy=127.0.0.1:$socks_inport
            ;;
        *)
            ;;
    esac
}

run_zm_proxy()
{
    docker_opts=""
    docker_bind="" 

    # docker_opts+='run -it --rm --name proxy --net=host --privileged'
    docker_opts='run -i -d --name proxy --net=host --privileged'
    test -z "$http_proxy" || docker_opts+=" -e http_proxy=$http_proxy"
    test -z "$https_proxy" || docker_opts+=" -e https_proxy=$https_proxy"
    test -z "$docker_iface" || docker_opts+=" -e docker_iface=$docker_iface"
    test -z "$socks_proxy" || docker_opts+=" -e socks_proxy=$socks_proxy"
    test -z "$ignore_addrs" || docker_opts+=" -e ignore_addrs=$ignore_addrs"

    if [ -e $cur_dir/supervisord.conf ];then
        docker_bind+="-v $cur_dir/supervisord.conf:/etc/supervisord.conf"
    fi

    id=$(docker ps -a --filter name=proxy -q)
    if [ -n "$id" ];then
        docker stop proxy
        docker rm proxy
    fi
    docker $docker_opts $docker_bind zeroman/proxy
}


run_shadowsocks()
{
    name=ss_proxy

    SS_PASSWORD=toor
    SS_ENCRPY=rc4-md5
    SS_PORT=1984
    # SS_ENCRPY=aes-256-cfb

    # docker_opts='run -i -d --name $name --net=host --privileged'
    # docker_opts="run -it --rm --name $name -p $SS_PORT:$SS_PORT"
    docker_opts="run -i -d --name $name -p $SS_PORT:$SS_PORT"
    id=$(docker ps -a --filter name=$name -q)
    if [ -n "$id" ];then
        docker stop $name
        docker rm $name
    fi
    # ss_opts="ssserver -s 0.0.0.0  -p $SS_PORT -k $SS_PASSWORD -m $SS_ENCRPY --fast-open -vv"
    ss_opts="ssserver -s 0.0.0.0  -p $SS_PORT -k $SS_PASSWORD -m $SS_ENCRPY --fast-open"
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
        docker stop -t 5 proxy
        docker rm proxy
        # docker rmi zeroman/proxy 
        ;;
    127)
        run_zm_proxy socks
        ssh -N -D $socks_inport 127 -v
        ;;
    mxb)
        # export socks_proxy=127.0.0.1:1080
        export socks_proxy=127.0.0.1:7070
        run_zm_proxy socks
        ;;
    test)
        ;;
    ss|shadowsocks)
        run_shadowsocks
        ;;
    sl|sslocal)
        run_zm_proxy socks
        shift
        # sslocal -s 服务器地址 -p 服务器端口 -l 本地端端口 -k 密码 -m 加密方法
        SS_PASSWORD=toor
        SS_ENCRPY=rc4-md5
        SS_PORT=1984
        sslocal -s $1 -p $SS_PORT -l $socks_inport -k $SS_PASSWORD -m $SS_ENCRPY 
        ;;
    log)
        docker exec -it proxy cat /root/stderr
        docker exec -it proxy cat /root/stdout
        ;;
    *)
        run_zm_proxy $@
        ;;
esac
