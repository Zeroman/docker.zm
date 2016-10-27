#!/bin/bash - 



case $1 in
    c|clean)
        docker-compose stop 
        docker-compose rm
        ;;
    shell)
        docker exec -it samba bash
        ;;
    *)
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
esac
