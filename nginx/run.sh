#!/bin/bash - 
#===============================================================================
#
#          FILE: run.sh
# 
#         USAGE: ./run.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 10/20/2016 16:43
#      REVISION:  ---
#===============================================================================




case $1 in
    key)
        openssl req -x509 -nodes -newkey rsa:2048 -keyout usms.key -out usms.crt -subj \
            "/C=CN/ST=Guangdong/L=Shenzhen/O=ZNV/OU=usms.znv.com/CN=usms.znv.com"
        ;;

    c|clean)
        docker-compose stop
        docker-compose rm -vf
        ;;
    l|log)
        docker-compose logs -f
        ;;
    *)
        docker-compose up -d
        ;;
esac
