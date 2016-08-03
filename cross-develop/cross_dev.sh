#!/bin/bash

# set -x

cmd=""
user=developer
for arg in $*
do
    if [ "$arg" == "nfs" ];then
        mkdir -p /nfs
        mkdir -p /run/sendsigs.omit.d/
        . /etc/default/nfs-common
        . /etc/default/nfs-kernel-server
        echo "/nfs *(rw,sync,no_subtree_check,fsid=0,no_root_squash)" > /etc/exports
        /etc/init.d/rpcbind start
        /etc/init.d/nfs-kernel-server start
    elif [ "$arg" == "tftp" ];then
        mkdir -p /tftp
        /etc/init.d/tftpd-hpa start
    elif [ "$arg" == "root" ];then
        user=root
    else
        cmd+="$arg "
    fi
done

if [ -e /dev/ttyUSB[0-9] ];then
    chmod 777 /dev/ttyUSB[0-9]
fi

if [ "$user" != "root" ];then
    if [ -n "$cmd" ];then
        su -c "$cmd" developer
    else
        su developer 
    fi
else
    bash
fi

if [ $(expr match "$*" ".*tftp") -ne 0 ];then
    /etc/init.d/tftpd-hpa stop
fi

if [ $(expr match "$*" ".*nfs") -ne 0 ];then
    /etc/init.d/nfs-kernel-server stop
    /etc/init.d/rpcbind stop
fi
