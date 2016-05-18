#!/bin/bash

# set -x

cmd=""
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
    else
        cmd+="$arg "
    fi
done

export uid=$UID gid=$UID 
echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd 
echo "developer:x:${uid}:" >> /etc/group 
echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer
chmod 0440 /etc/sudoers.d/developer
# chown ${uid}:${gid} -R /home/developer

if [ -n "$cmd" ];then
    su -c "$cmd" developer
else
    su developer 
fi

if [ $(expr match "$*" ".*tftp") -ne 0 ];then
    /etc/init.d/tftpd-hpa stop
fi

if [ $(expr match "$*" ".*nfs") -ne 0 ];then
    /etc/init.d/nfs-kernel-server stop
    /etc/init.d/rpcbind stop
fi
