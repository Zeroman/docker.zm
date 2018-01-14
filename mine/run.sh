#!/bin/bash - 


case $1 in
    r)
        docker run --name zcash -d kmdgeek/nheqminer /nheqminer -l cn1-zcash.flypool.org:3333 -u t1Y7Udc4sRAeNeML9CR1HeeUKVEHfRWZ9EN.zero
        ;;
    l)
        docker logs zcash -f
        ;;
    c)
        docker kill zcash
        docker rm zcash
        ;;
    info)
        firefox http://zcash.flypool.org/miners/t1Y7Udc4sRAeNeML9CR1HeeUKVEHfRWZ9EN
        ;;
esac



