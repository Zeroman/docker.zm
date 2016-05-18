用docker做嵌入式开发基础环境
================
之前一直使用debian stable，觉得软件不够新，又换为debian unstable，还是觉得不够新，接着换为archlinux。
嵌入式开发的环境却受到了影响，有些软件比如kermit在不同发行版配置都有区别。所以直接上docker吧。

### 软件环境
使用debian:jessie吧，软件变化少，做嵌入式开发不需要太新的软件。还要兼容32位体系架构。

基本的软件配置如下：
> nfs-kernel-server net-tools ckermit automake autoconf 
> tftp-hpa tftpd-hpa bc procps kmod dosfstools dos2unix 
> make gcc-multilib libncurses5-dev u-boot-tools lzma 
> lzop zlib1g:i386

* nfs-kernel-server: 用做nfs root filesystems
* tftpd-hpa: tftp服务端，使用tftpd-hpa，配置简单，可以不依赖inetd
* ckermit: 串口工具，比minicom好用太多
* gcc-multilib: 兼容32位工具
* zlib1g:i386: 编译android用到
* lzma lzop: 编译内核有可能用到
* automake autoconf make: 基础编译工具链

### 启动脚本
必须自动开启nfs服务器，tftp服务器。
脚本内容如下：
``` bash
#!/bin/bash

set -e

echo "/nfs *(rw,sync,no_subtree_check,fsid=0,no_root_squash)" > /etc/exports

. /etc/default/nfs-kernel-server
. /etc/default/nfs-common

mkdir -p /run/sendsigs.omit.d/
mkdir -p /tftp /nfs

service tftpd-hpa start
service rpcbind start
service nfs-kernel-server start

/bin/bash

service tftpd-hpa stop
service nfs-kernel-server stop
service rpcbind stop
```

### Dockerfile
``` Dockerfile
FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

ADD sources.list /etc/apt/sources.list

RUN dpkg --add-architecture i386 && apt-get update 

RUN apt-get install -y --no-install-recommends \
        nfs-kernel-server net-tools ckermit automake autoconf \
        tftp-hpa tftpd-hpa bc procps kmod dosfstools dos2unix \
        make gcc-multilib libncurses5-dev u-boot-tools lzma \
        lzop zlib1g:i386

# RUN apt-get install -y --no-install-recommends lzma

ADD cross_dev.sh /bin/cross_dev.sh

ENTRYPOINT ["/bin/cross_dev.sh"]

```


### 使用方法
docker直接启动命令太长，所以写了个脚本。
使用方法如下：
```
# 编译镜像
./run.sh b 
# 测试nfs和tftp
./run.sh t
# 启动镜像
./run.sh r
# 清除镜像
./run.sh c
```

run.sh 内容如下：
``` bash
#!/usr/bin/env sh

cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)


run_image()
{
    if ! modprobe nfsd nfsv3 nfsv4;then
        sudo modprobe nfsd nfsv3 nfsv4
    fi

    mkdir -p $cur_dir/nfs
    mkdir -p $cur_dir/tftp

    id=$(docker ps -a --filter name=cross-dev -q)
    if [ -z "$id" ];then
        docker run -it --rm --name cross-dev --net=host --privileged \
            -v ~/.kermrc:/root/.kermrc:ro \
            -v ~/.bashrc:/root/.bashrc:ro \
            -v $cur_dir/tftp:/srv/tftp \
            -v $cur_dir/nfs:/nfs \
            -v $cur_dir:/work \
            -w /work \
            cross-dev
    else
        docker start -i cross-dev
    fi
}

test_cross_dev()
{
    if [ ! -e /nfs/$cur_filename ];then
        sudo cp -fv $cur_path $cur_dir/nfs/
        return
    fi

    echo "test nfs kernel server."
    touch /nfs/test_nfs
    mount -v -t nfs -o nolock localhost:/ /mnt
    ls -l /mnt/
    rm -fv /nfs/test_nfs
    ls -l /mnt/
    umount /mnt

    echo "test tftpd-hpa."
    echo "test file" > /srv/tftp/test_file
    cd /tmp/
    tftp 127.0.0.1 -c get test_file
    md5sum /srv/tftp/test_file test_file
}


case $1 in
    b|build)
        docker build -t cross-dev --no-cache .
        ;;
    r|run)
        shift
        run_image $@
        ;;
    t|test)
        test_cross_dev
        ;;
    c|clean)
        rmdir nfs
        rmdir tftp
        docker rm cross-dev
        docker rmi cross-dev
        ;;
    *)
        run_image $@
        ;;
esac

```

git clone 地址：
``` bash
git clone https://github.com/Zeroman/docker.cross-dev.git
```

More Info
=========
* <http://www.51feel.info>
* <https://github.com/Zeroman/docker.cross-dev.git>
