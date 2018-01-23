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

run_ssr_server()
{
    docker run -it --rm --name ssr_server \
        -e SERVER_ADDR=0.0.0.0 \
        -e SERVER_PORT=8388 \
        -e PASSWORD=sfjk \
        -e METHOD=aes-256-cfb \
        -e PROTOCOL=auth_aes128_sha1 \
        -e OBFS=plain \
        -p 3399:8388 \
        -p 3399:8388/udp \
        esme518/docker-shadowsocksr 
}

run_ssr_client()
{
    docker run -it --rm --name ssr_client \
        -p $socks_inport:8388 \
        -p $socks_inport:8388/udp \
        esme518/docker-shadowsocksr \
        sslocal -s 192.168.199.170 -p 3399 \
        -b 0.0.0.0 -l 8388 \
        -k sfjk -m aes-256-cfb -o plain -O auth_aes128_sha1 -vv
}

run_gg_ssr_client()
{
    docker run -it --rm --name ssr_client \
        -p $socks_inport:8388 \
        -p $socks_inport:8388/udp \
        esme518/docker-shadowsocksr \
        sslocal -s 35.201.241.163 -p 9999 \
        -b 0.0.0.0 -l 8388 \
        -m aes-256-cfb -o plain -O auth_aes128_sha1 \
        -k z***** -vv
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
    c|clean)
        docker stop -t 5 proxy
        docker rm proxy
        # docker rmi zeroman/proxy 
        ;;
    gg)
        export socks_proxy=127.0.0.1:$socks_inport
        run_zm_proxy 
        ssh -N -D $socks_inport gg -v
        ;;
    test)
        ;;
    log)
        docker exec -it proxy cat /root/stderr
        docker exec -it proxy cat /root/stdout
        ;;
    ssrs)
        run_ssr_server
        ;;
    ssrc)
        run_ssr_client
        ;;
    gg_ssrc)
        run_gg_ssr_client
        ;;
    *)
        ;;
esac
