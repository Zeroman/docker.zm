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
            export gateway="no"
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

    # docker_opts+='run -it --rm --name proxy --network host --privileged'
    docker_opts='run -i -d --name proxy --network host --privileged'
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
    touch /tmp/.proxy
}

run_ssr2_client()
{
    docker run -it --rm --name ssr_client \
        -p $socks_inport:8388 \
        -p $socks_inport:8388/udp \
        breakwa11/shadowsocksr \
        sslocal -s 192.168.199.170 -p 3399 \
        -b 0.0.0.0 -l 8388 \
        -k sfjk -m aes-256-cfb -o http_post -O auth_aes128_sha1 -vv
}

run_ssr_client()
{
    docker run -it --rm --name ssr_client \
        -p $socks_inport:8388 \
        -p $socks_inport:8388/udp \
        breakwa11/shadowsocksr \
        ./local.py -s 35.221.208.34 -p 443 \
        -b 0.0.0.0 -l 8388 \
        -k 'orz2019!' -m chacha20-ietf -o 'tls1.2_ticket_auth' -O auth_sha1_v4 -vv
}


run_ssr_server()
{
    docker run -it --rm --name ssr_server \
        -e SERVER_ADDR=0.0.0.0 \
        -e SERVER_PORT=8388 \
        -e PASSWORD=sfjk \
        -e METHOD=aes-256-cfb \
        -e PROTOCOL=auth_aes128_sha1 \
        -e OBFS=http_post \
        -p 3399:8388 \
        -p 3399:8388/udp \
        breakwa11/shadowsocksr 
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
        docker stop proxy
        rm -fv /tmp/.proxy
        docker rm proxy
        # docker rmi zeroman/proxy 
        ;;
    gg)
        export socks_proxy=127.0.0.1:$socks_inport
        #run_zm_proxy 
        #ssh -N -D $socks_inport aly -v
        ssh -N -D $socks_inport rb -v
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
    socks)
        export socks_proxy=127.0.0.1:$socks_inport
        run_zm_proxy 
        ;;
    show|iptables)
        #sudo iptables -nv -L
        sudo iptables -t nat -nvL
        ;;
    ts)
        echo "7071"
        export socks_proxy=127.0.0.1:7071
        run_zm_proxy 
        ;;
    *)
        export socks_proxy=127.0.0.1:$socks_inport
        run_zm_proxy 
        ;;
esac
