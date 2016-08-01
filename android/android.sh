#!/bin/bash

export uid=$UID gid=$UID 
echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd 
echo "developer:x:${uid}:" >> /etc/group 
echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer
chmod 0440 /etc/sudoers.d/developer
chown ${uid}:${gid} /home/developer

if [ -z "$@" ];then
    su -c /opt/android-studio/bin/studio.sh developer 
else
    su -c "$@" developer
fi
