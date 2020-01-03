#!/bin/bash - 


cur_dir=$PWD
cur_path=$(readlink -f $0)
cur_workdir=${cur_path%/*}
cur_filename=$(basename $cur_path)

case $1 in
    c|clean)
        docker-compose stop 
        docker-compose rm -f
        ;;
    shell)
        docker exec -it samba bash
        ;;
    test)
        docker run -it --name samba -p 139:139 -p 445:445 -v /tmp/.samba:/temp -d dperson/samba \
            -u "abc;abcd" \
            -u "e1;e11" \
            -u "e2;e22" \
            -s "temp;/temp" \
            -s "test;/mnt;yes;no;no;abc" \
            -s "users;/srv;no;no;no;e1,e2" \
            -s "example1 private;/example1;no;no;no;e1" \
            -s "example2 private;/example2;no;no;no;e2"

        ;;
    -h|help)
        docker run -it --rm dperson/samba -h
        ;;
    *)
        samba_dir=/tmp/.samba
        mkdir -p -m 0777 $samba_dir
        sudo chown $USER.$USER $samba_dir
        sudo chmod 777 $samba_dir
        docker-compose -f $cur_workdir/docker-compose.yml up -d 
        ;;
esac
