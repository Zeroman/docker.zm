#!/bin/bash - 


# https://github.com/NVIDIA/nvidia-docker
# http://blog.csdn.net/smilingc/article/details/53760721
# https://github.com/CultClassik/nv-docker-equihash-ewbf
# https://hub.docker.com/u/cultclassik/

wallet=t1Y7Udc4sRAeNeML9CR1HeeUKVEHfRWZ9EN
server=zec-cn1.dwarfpool.com
worker=zero_$RANDOM
# cn1-zcash.flypool.org

case $1 in
    r)
        docker run --name zcash -d kmdgeek/nheqminer /nheqminer -l $server:3333 -u $wallet.$worker
        ;;
    l)
        docker logs zcash -f
        ;;
    c)
        docker kill zcash
        docker rm zcash
        ;;
    info)
        # firefox http://zcash.flypool.org/miners/t1Y7Udc4sRAeNeML9CR1HeeUKVEHfRWZ9EN
        firefox http://dwarfpool.com/zec/address?wallet=$wallet
        ;;
esac



